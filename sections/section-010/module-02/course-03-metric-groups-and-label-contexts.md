# Metric Groups And Label Contexts

Turning on metrics is only the first step. Hubble offers several groups of metrics, and each group has options that decide which labels a counter carries. A label with many different values makes a metric expensive. This part lists the groups, explains what each one counts and shows how the context options shape the labels.

## The groups and their counters

You name a group in the `hubble-metrics` key of the `cilium-config` ConfigMap, or in the Helm value `hubble.metrics.enabled`. The groups and their main counters are:

| Group | Main counters | What it counts |
| --- | --- | --- |
| `drop` | `hubble_drop_total` | Dropped packets, by reason and protocol |
| `flow` | `hubble_flows_processed_total` | All flows, by type, subtype, verdict and protocol |
| `tcp` | `hubble_tcp_flags_total` | TCP packets by flag, such as SYN and FIN |
| `icmp` | `hubble_icmp_total` | Internet Control Message Protocol messages by type |
| `port-distribution` | `hubble_port_distribution_total` | Destination ports that are used |
| `dns` | `hubble_dns_queries_total`, `hubble_dns_responses_total` | DNS queries and responses, from the DNS proxy |
| `httpV2` | `hubble_http_requests_total`, `hubble_http_request_duration_seconds` | HTTP requests and their duration, from the HTTP proxy |
| `policy` | `hubble_policy_verdicts_total` | Policy verdicts by direction and match type |
| `flows-to-world` | `hubble_flows_to_world_total` | Flows that go to the `world` identity |

The groups `dns` and `httpV2` depend on layer 7 visibility. They stay empty for traffic that no layer 7 rule selects. The other groups work on layer 3 and layer 4 events.

## Options after the group name

A group can carry options. In the ConfigMap, you write the options after a colon and separate them with semicolons. The groups themselves are separated with spaces. This value enables four groups, and the second one has options:

```text
drop flow:sourceContext=workload-name;destinationContext=workload-name tcp dns:query
```

The option `sourceContext` and the option `destinationContext` add labels that name the source and the destination of the flow. The value chooses how the workload is named. Common values are `identity`, `namespace`, `pod`, `pod-short`, `workload`, `workload-name`, `app`, `dns`, `ip` and `reserved-identity`. You can join several values with `|`, and Cilium uses the first one that gives a result. For example `workload-name|reserved-identity` names a workload when there is one and the reserved identity (such as `world`) when there is not.

The `dns` group has the option `query`, which adds the queried name as a label. The option `ignoreAAAA` leaves out queries for IPv6 addresses. The `httpV2` group takes `exemplars=true` and a `labelsContext` option, for example `labelsContext=source_namespace,destination_namespace,traffic_direction`, which chooses the extra labels.

## The cost of a label

Prometheus stores one time series for each combination of label values. The counter `hubble_drop_total` with only the labels `reason` and `protocol` has a handful of series. If you add the source pod and the destination pod, the number of series grows with the number of pod pairs, and pod names change at every restart. The same is true for the label `query` on DNS metrics: every name that a pod looks up creates a new series.

The safe habit is to start with the group names and no options, then add a context only when you have a question that needs it, and prefer stable names such as `workload-name` and `namespace` over `pod` or `ip`.

## Try the options

Enable the groups in the playground with a patch. The `rollout restart` makes the agents read the new value:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"drop flow:sourceContext=workload-name;destinationContext=workload-name","hubble-metrics-server":":9965"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

Then read the flow counter through the Kubernetes API pod proxy:

```sh
pod=$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" | grep hubble_flows_processed_total
```

Each line is one series. With the context options, the lines include labels for the source and destination, so you can tell which workload pairs produce the flows. Remove the options and repeat to see how the number of lines drops.

You now know what each group counts and how a label choice changes the size of the data. The next question is how a monitoring system collects these numbers.

## Common pitfalls

> [!WARNING]
> The groups are separated by spaces in the ConfigMap and by commas in the Helm value, so a copied value may not work in the other place. A misspelled group name is ignored or stops the agent from starting the metrics server, so check the agent log after a restart. A context such as `pod` or `ip` creates many series and can overload Prometheus. The `dns` and `httpV2` groups show nothing for traffic that no layer 7 rule selects.

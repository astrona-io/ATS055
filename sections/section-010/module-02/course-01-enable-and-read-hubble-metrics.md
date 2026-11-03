# Enable And Read Hubble Metrics

A flow record tells you about one event, but operations teams ask different questions. How many packets did a policy drop in the last hour? Did the rate of DNS errors rise after a release? A person cannot answer these by reading flows one by one. Hubble metrics answer them: the agent counts the flows and exposes the counters in a format that a monitoring system can read. This part shows how to turn the metrics on, how the agent serves them and how to read one counter.

## Metrics and flows are different data

A flow is a full record of one event, with names, ports and a verdict. It lives in the ring buffer and is gone when the buffer wraps around. A metric is an aggregate: a number that grows or changes as events arrive. A metric keeps only a few labels, such as the reason of a drop or the protocol, and it keeps no record of single requests.

Because of this, metrics are small and can be stored for a long time. They show trends and rates and they can raise alerts. They cannot tell you which request failed. You use a metric to learn that something changed and a flow to learn what happened.

## The metric groups

Hubble groups its metrics. You choose which groups to turn on, because each group costs memory and processing in the agent. The common groups are:

- `drop`: counts dropped packets and labels them with the drop reason and the protocol.
- `flow`: counts all flows that Hubble processed, labelled by type and verdict.
- `tcp`: counts TCP flags, for example connection starts and resets.
- `dns`: counts DNS (Domain Name System) requests and responses and their response codes.
- `icmp`: counts ICMP (Internet Control Message Protocol) messages.
- `port-distribution`: counts flows per destination port.
- `httpV2`: counts HTTP requests and their latency, with the method and the status code.

The `dns` and `httpV2` groups only count what the proxy sees at layer 7, so they have data only for traffic that a layer 7 policy sends through the proxy. The other groups work on layer 3 and 4 events.

Each metric name starts with `hubble_`. For example, the `drop` group exposes `hubble_drop_total`, and the `flow` group exposes `hubble_flows_processed_total`.

## How the agent serves the metrics

Hubble metrics are off until you set two keys in the `cilium-config` ConfigMap. The key `hubble-metrics` holds a space-separated list of the groups. The key `hubble-metrics-server` holds the address where the agent serves them, for example `:9965`, which means port 9965 on all addresses of the node. With Helm, the matching values are `hubble.metrics.enabled` for the list and the port setting of the metrics service.

The agent reads the ConfigMap only when it starts. After you change the keys, you must restart the Cilium DaemonSet. This is the most common reason that a change seems to have no effect.

Look at the keys before the change:

<!-- astrona:playground:renew -->

```sh
kubectl -n kube-system get configmap cilium-config -o yaml | grep -i hubble
```

The list has `enable-hubble` and the socket path, but no `hubble-metrics` and no `hubble-metrics-server`. Metrics are off.

## Turn on the drop and flow metrics

Patch the ConfigMap with `kubectl patch`. The JSON patch below merges two keys into the `data` section:

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"drop flow","hubble-metrics-server":":9965"}}'
```

The ConfigMap now holds the new keys, but the running agent still uses the old values. Restart it and wait until the rollout finishes:

```sh
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=180s
```

The first command makes the DaemonSet controller replace the agent pods one by one. The second command waits for the new pod to be ready. On a single-node cluster, the node has no agent for a short time during the restart, and the datapath rules stay in place while the new agent starts.

## Read the metrics through the Kubernetes API

The metrics endpoint listens on the pod, on port 9965, at the path `/metrics`. You can reach it without a port-forward through the pod proxy of the Kubernetes API server. First find the name of the agent pod:

```sh
kubectl -n kube-system get pods -l k8s-app=cilium -o name
```

Then read the endpoint. Replace `<AGENT_POD>` with the pod name from the output, without the `pod/` prefix:

```sh
kubectl get --raw /api/v1/namespaces/kube-system/pods/<AGENT_POD>:9965/proxy/metrics | grep hubble_drop_total
```

You see one or more lines for `hubble_drop_total`. Each line is one label set, with the drop reason and the protocol as labels, followed by the counter value. Read the number once, wait ten seconds, and read it again. The `rogue` pod sends a request every 5 seconds and the policy drops each one, so the counter increases between the two reads.

Now compare with the flow counter:

```sh
kubectl get --raw /api/v1/namespaces/kube-system/pods/<AGENT_POD>:9965/proxy/metrics | grep hubble_flows_processed_total
```

This counter is larger than the drop counter, because it counts all flows, forwarded and dropped, and it has the verdict as a label.

## What the counters mean

A counter only grows while the agent runs. After an agent restart, it starts again from zero. A monitoring system handles this by reading the rate of change, not the raw number. You should therefore never compare a raw counter before and after a restart.

The drop counter counts events, not requests. A single request with retries produces several drops. The counter also depends on the metric group options: some groups accept options such as extra labels, which add detail and increase the number of series that the monitoring system stores.

A metric that does not appear can have three causes. The group is not in the `hubble-metrics` list. The agent was not restarted after the change. Or the group has no events yet, for example `httpV2` without any layer 7 traffic.

You now know how to turn on the Hubble metrics, how the agent serves them, and how to read a counter from the endpoint. The drop counter you read depends on a second limit of Hubble: how many flows the agent keeps.

## Common pitfalls

> [!WARNING]
> Editing `cilium-config` does not change the running agent; restart the DaemonSet and wait for the rollout. The list in `hubble-metrics` is separated by spaces, not by commas. Setting the list without `hubble-metrics-server` leaves the metrics without an address. The `dns` and `httpV2` groups stay empty until layer 7 visibility exists for the traffic. Counters restart from zero when the agent restarts.

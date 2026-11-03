# HTTP And DNS Metrics

Layer 7 flows are detailed, but they live in a small buffer. Metrics keep a count of requests, errors and durations for a long time. The groups `httpV2` and `dns` turn the layer 7 events into counters. This part enables them, reads the counters and explains the labels.

## The counters

The `httpV2` group exposes two main series. The counter `hubble_http_requests_total` counts requests, and the histogram `hubble_http_request_duration_seconds` records how long the answers took. Their labels include the HTTP method, the status code, the protocol and, by default, the source and destination information that the label context chooses. The `dns` group exposes `hubble_dns_queries_total` and `hubble_dns_responses_total`, with labels such as the query type and the response code.

Both groups read events from the proxy. The counters have no series until a layer 7 rule selects traffic and a request or query passes.

## Make traffic pass the proxy

Save this policy as `probe-ingress-http.yaml`. It adds an HTTP rule to the policy of the `probe`, so that the proxy sees the requests of `shuttle`:

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-ingress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: shuttle
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
      rules:
        http:
        - method: GET
          path: /get
```

Apply it:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f probe-ingress-http.yaml
```

Then enable the metric group, with a label context that keeps the number of series small, and restart the agents:

```sh
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"httpV2:labelsContext=source_namespace,destination_namespace,traffic_direction","hubble-metrics-server":":9965"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
```

## Read the counter

Send one allowed and one refused request, then read the metrics through the Kubernetes API pod proxy:

```sh
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/headers
pod=$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" | grep hubble_http_requests_total
```

You see series that differ by the `method`, the `status` and the namespace labels. The allowed request has the status `200`, and the refused request has the status `403`. A monitoring system can compute the error ratio from these series.

## Context and cost

The option `labelsContext` accepts names such as `source_ip`, `source_namespace`, `source_workload`, `destination_ip`, `destination_namespace`, `destination_workload` and `traffic_direction`. Labels with addresses or pod names create many series. Namespace and workload labels stay stable. The option `exemplars=true` adds trace identifiers to some series, and it needs OpenMetrics output and a tracing system that uses them.

For DNS, the group `dns:query` adds the queried name as a label. Use it only if the set of names is small and known. A query label on a busy cluster can create thousands of series.

You now have a counter and a way to alert on error rates. The proxy that produces them has a cost that you should know before you widen the rules.

## Common pitfalls

> [!WARNING]
> The counters have no series until layer 7 traffic passes the proxy. The group name in the ConfigMap is `httpV2`, and the older `http` group has fewer labels and is not the same. A label with source or destination addresses can overload the monitoring system. The agent must restart before a changed metric list takes effect.

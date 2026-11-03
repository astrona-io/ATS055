# Question

Solve this question on: `terminal`

The policy `probe-ingress` in `starfleet` already lets `shuttle` send `GET /get` to the `probe`, so the proxy sees every HTTP request. The team wants a counter of those requests that a monitoring system can read.

1. Enable the Hubble metric group `httpV2` and serve the metrics on port 9965 of every Cilium agent.
2. Make the agents load the change, and wait until they are ready.
3. Send requests from `shuttle` to `http://probe.starfleet:8080/get` and find the counter `hubble_http_requests_total` in the metrics of an agent.

Do not change the policy or the workloads.

`kubectl` already points at the cluster as the cluster administrator.

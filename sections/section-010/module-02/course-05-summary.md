# Summary

Flow records and metrics give two different views of the same traffic. A flow is a detailed record of one event and is kept only for a short time. A metric is a counter or a rate that is cheap to keep and shows trends.

## What you learned

Hubble metrics are off until you set two keys in the Cilium ConfigMap: the list of metric groups and the address where the agent serves them. The common groups are drop, flow, tcp, dns, icmp, port-distribution and httpV2. Each group costs memory and processing, so you enable only what you need. The DNS and HTTP groups have data only for traffic that passes the layer 7 proxy.

The agent reads its ConfigMap only at start. After a change, the DaemonSet must be restarted and the rollout must finish. You can then read the metrics endpoint of an agent on port 9965 through the Kubernetes API pod proxy and find counters such as the number of dropped flows. A counter grows while the agent runs and starts from zero after a restart.

The flows live in a ring buffer in the memory of the agent. The capacity must be one less than a power of two, with 4095 as the chart default. The look-back time is the capacity divided by the flow rate, and the status command shows both the fill level and the rate. A larger buffer costs memory.

A restart of the agent empties the buffer and resets the counters, but it does not stop the traffic of running pods. You therefore read the flows you need before you apply a change. For history beyond the buffer, use metrics for trends and a flow exporter for stored flows.

## Key facts

- `hubble-metrics` takes a space-separated list of groups; `hubble-metrics-server` takes the address, for example `:9965`.
- `hubble-event-buffer-capacity` takes 2^n - 1; the chart default is 4095.
- Changes to the ConfigMap need a restart of the Cilium DaemonSet.
- Metrics show how often; flows show what happened.
- A restart clears the buffer and resets the counters.

<!-- astrona:playground:destroy -->

# Question

Solve this question on: `terminal`

An on-call engineer reports that something in `outpost` cannot reach the `probe` in `starfleet`. The team has no Hubble metrics and a short flow history. Set up the observation and write the findings.

1. Enable the Hubble metrics `drop` and `flow`, served on port 9965 of the Cilium agent, and set the flow buffer to 16383 flows. Make the agents load the change.
2. Use Hubble to find the source pod, the destination pod, the destination port and the drop reason of the dropped traffic that comes from `outpost`.
3. Create the ConfigMap `drop-report` in `starfleet` with the keys `source` (namespace/pod), `destination` (namespace/pod), `port` and `reason`.
4. Confirm that the metric `hubble_drop_total` is exposed by the agent.

Do not change the policy or the workloads.

`kubectl` already points at the cluster as the cluster administrator.

# Question

Solve this question on: `terminal`

The team wants a count of dropped packets over time and a longer flow history. The pod `rogue` in `outpost` is dropped by the policy `probe-ingress` every 5 seconds, which makes a good test.

1. Enable the Hubble metrics `drop` and `flow` and serve them on port 9965 of every Cilium agent.
2. Set the Hubble flow buffer to hold 8191 flows.
3. Make the agents load the change, and wait until they are ready.

Do not change the policy or the workloads. The grader reads the ConfigMap, the buffer size from Hubble and the metrics from the agent.

`kubectl` already points at the cluster as the cluster administrator.

# Question

Solve this question on: `terminal`

The security team wants a file that records every dropped flow, so that a log collector can read it later. The pod `rogue` in `outpost` is dropped by the policy `probe-ingress` every 5 seconds, which makes a good test.

1. Make the Hubble server write flows to the file `/var/run/cilium/hubble/events.log` in every Cilium agent pod.
2. Export only flows with the verdict `DROPPED`.
3. Make the agents load the change, and wait until they are ready.

Do not change the policy or the workloads. The grader reads the ConfigMap and the file in the agent pod.

`kubectl` already points at the cluster as the cluster administrator.

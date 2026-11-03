# Question

Solve this question on: `terminal`

The pod `rogue` in `outpost` keeps sending requests to the `probe` in `starfleet`. Something drops them, and nobody knows which pod is affected.

1. Use `hubble observe` to find the pod whose requests to the `probe` are dropped, the destination port and the verdict.
2. Create the ConfigMap `cli-report` in `starfleet` with the keys `dropped-source` (namespace/pod), `destination` (namespace/pod), `destination-port` and `verdict`.
3. Allow only that pod: extend `probe-ingress` so that the pod labelled `app=rogue` in `outpost` may reach port 8080. Keep `shuttle` allowed and keep `drifter` refused.

`kubectl` already points at the cluster as the cluster administrator.

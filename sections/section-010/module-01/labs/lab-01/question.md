# Question

Solve this question on: `terminal`

The `probe` Service in `starfleet` is protected by the policy `probe-ingress`. Two clients call it: the pod `shuttle` in `starfleet` and the pod `drifter` in `outpost`. Use Hubble to find out what the network did with each request.

1. From `shuttle`, send one request to `http://probe.starfleet:8080/get`. From `drifter`, send one request to the same address.
2. Find both flows with `hubble observe` and read the verdict, the source and the drop reason.
3. Create the ConfigMap `flow-report` in `starfleet` with these keys: `forwarded-source` (namespace/pod of the client whose request was forwarded), `dropped-source` (namespace/pod of the client whose request was dropped), `drop-reason` (the reason Hubble shows for the drop) and `dropped-destination-port`.

Do not change the policy or the workloads. The grader reads Hubble again, so the report must match the real flows.

`kubectl` already points at the cluster as the cluster administrator.

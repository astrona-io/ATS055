# Question

Solve this question on: `terminal`

The new pod `cadet` in `starfleet` cannot reach the `probe` on port 8080, but `shuttle` can. Nobody changed the pods. Use Hubble to find out why, then fix it.

1. Find the dropped flows of `cadet` in Hubble and read the drop reason and the policy that decided.
2. Extend the policy `probe-ingress` so that the pod labelled `app=cadet` in `starfleet` may reach port 8080. Keep `shuttle` allowed.
3. Send a request from `cadet` to `http://probe.starfleet:8080/get` and confirm in Hubble that the policy verdict is now forwarded.

The pods `drifter` and `rogue` in `outpost` must stay refused. Do not touch the workloads.

`kubectl` already points at the cluster as the cluster administrator.

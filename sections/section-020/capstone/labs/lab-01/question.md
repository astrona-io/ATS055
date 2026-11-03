# Question

Solve this question on: `terminal`

The team needs application-level visibility of what `shuttle` sends to the `probe`.

1. Change `probe-ingress` so that only `shuttle` may send `GET /get` to port 8080.
2. Create a policy for `shuttle` that makes its DNS queries visible (cluster DNS in `kube-system`, labels `k8s-app=kube-dns`, port 53 over UDP and TCP, all names) and still allows the `probe` on port 8080.
3. Enable the Hubble metric `httpV2` so that the agent exposes HTTP request counts on port 9965. Make the agents load the change.
4. Send traffic from `shuttle` and confirm in Hubble that you see the HTTP flows and the DNS flows.

Keep `drifter` refused and do not touch the workloads.

`kubectl` already points at the cluster as the cluster administrator.

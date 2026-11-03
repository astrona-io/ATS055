# Question

Solve this question on: `terminal`

The policy `probe-ingress` in `starfleet` lets `shuttle` reach the `probe` on TCP port 8080, but Hubble shows no HTTP details. The team wants to see each HTTP request and to allow only `GET /get`.

1. Change `probe-ingress` so that `shuttle` may send only `GET` requests to the path `/get` on port 8080. Keep `shuttle` as the only allowed source.
2. Send `GET /get` and `GET /headers` from `shuttle` to `http://probe.starfleet:8080`.
3. Confirm in Hubble that the `/get` request is forwarded and the `/headers` request is dropped, both as HTTP flows.

Do not touch the workloads.

`kubectl` already points at the cluster as the cluster administrator.

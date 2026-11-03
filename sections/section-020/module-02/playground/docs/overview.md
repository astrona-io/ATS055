# Overview: DNS Visibility And Protocol Limits (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay (Deployment `hubble-relay` and Service `hubble-relay` in `kube-system`).
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- `kubectl` already points at the cluster as the cluster administrator.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.
- The policy `probe-ingress` allows `shuttle` to reach port 8080 of the `probe`.
- No policy selects `shuttle` yet, so its egress traffic is unrestricted and Hubble shows no DNS details.

## Things to try

- Run `hubble observe --pod starfleet/shuttle --protocol UDP --last 10` after a request by name and see that port 53 flows have no DNS fields.
- Apply a policy with `rules.dns` and `matchPattern: "*"` for `shuttle`, then run `hubble observe --type l7 --protocol dns`.
- Send a request to `https://example.com` and see that Hubble shows no HTTP fields for it.
- Remove the egress rule for the `probe` and see which request then fails.

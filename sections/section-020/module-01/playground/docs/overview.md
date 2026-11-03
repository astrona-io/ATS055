# Overview: L7 Visibility With An HTTP Policy (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay (Deployment `hubble-relay` and Service `hubble-relay` in `kube-system`).
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- `kubectl` already points at the cluster as the cluster administrator.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.
- The policy `probe-ingress` is a Layer 4 policy: it allows `shuttle` to reach port 8080 and has no HTTP rules.

## Things to try

- Send `GET /get` and `GET /headers` from `shuttle`, then run `hubble observe --pod starfleet/probe --last 20`. Note that no HTTP fields appear.
- Save and apply a policy with `rules.http` for `GET /get`, repeat both requests and run `hubble observe --type l7 --protocol http`.
- Repeat the `/headers` request and read the status code you get back.
- Change the rule path to a regular expression such as `/status/2..` and test `/status/200` and `/status/404`.

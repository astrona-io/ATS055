# Overview: Layer 7 Metrics And Protocol Limits (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay.
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- The policy `probe-ingress` lets only `shuttle` reach port 8080 of the `probe`. It has no HTTP rule yet.
- Hubble metrics are off.

## Things to try

- Apply a policy with an HTTP rule and read the HTTP flows with `hubble observe --protocol http`.
- Add `httpV2` to the key `hubble-metrics` and `:9965` to `hubble-metrics-server`, restart the agent and read `hubble_http_requests_total` through the Kubernetes API pod proxy.
- Send a request to an HTTPS address from `shuttle` and check that no HTTP flow exists for it.

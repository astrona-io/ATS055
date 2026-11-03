# Overview: Troubleshooting With Hubble (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay.
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter` and the pod `rogue`, which sends a request to the `probe` every 5 seconds.
- The policy `probe-ingress` lets only `shuttle` reach port 8080 of the `probe`.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.

## Things to try

- Find the drops with `hubble observe --verdict DROPPED --last 10` and read the drop reason.
- Show policy decisions with `hubble observe --type policy-verdict --last 10`.
- Compare with the agent view: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- cilium-dbg monitor --type drop`, and stop it with Control-C.
- List the nodes and namespaces that Hubble knows with `hubble list nodes` and `hubble list namespaces`.

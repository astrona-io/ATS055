# Overview: The Hubble UI And The Service Map (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay (Deployment `hubble-relay` and Service `hubble-relay` in `kube-system`).
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- `kubectl` already points at the cluster as the cluster administrator.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.
- The Hubble UI (Deployment and Service `hubble-ui` in `kube-system`), connected to Relay.
- The policy `probe-ingress` and the pod `rogue`, which produces a dropped edge in the service map.

## Things to try

- Open the UI with `kubectl -n kube-system port-forward service/hubble-ui 12000:80` and browse to `http://127.0.0.1:12000`.
- Select the namespace `starfleet` and then `outpost` and compare the service maps.
- Find the edge from `rogue` to `probe`, open the flows table and read the verdict.
- Send a request from `shuttle` and see the new edge appear.

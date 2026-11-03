# Overview: Hubble Components And Flow Records (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay (Deployment `hubble-relay` and Service `hubble-relay` in `kube-system`).
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- `kubectl` already points at the cluster as the cluster administrator.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.
- The `CiliumNetworkPolicy` `probe-ingress` in `starfleet`: the `probe` accepts TCP port 8080 only from `shuttle`.
- The pod `rogue` in `outpost`, which sends a request to the `probe` every 5 seconds. The policy drops it.

## Things to try

- Run `hubble status` and `hubble observe --last 20` inside the agent pod and name each field in one line of output.
- Send a request from `shuttle` and from `drifter` to `http://probe.starfleet:8080/get` and find both flows.
- Run `hubble observe --verdict DROPPED -o json --last 1` and read the `verdict`, `drop_reason_desc` and `traffic_direction` fields.
- List the Hubble pods and Services: `kubectl -n kube-system get pods,svc -l app.kubernetes.io/part-of=cilium`.

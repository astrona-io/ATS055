# Overview: Hubble Metrics And Observation Limits (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay (Deployment `hubble-relay` and Service `hubble-relay` in `kube-system`).
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- `kubectl` already points at the cluster as the cluster administrator.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.
- Hubble metrics are off and the flow buffer has its default size.
- The policy `probe-ingress` and the pod `rogue` produce a steady stream of dropped flows.

## Things to try

- Run `hubble status` and note `Current/Max Flows`.
- Read the ConfigMap: `kubectl -n kube-system get configmap cilium-config -o yaml | grep hubble`.
- Add `hubble-metrics: drop flow` and `hubble-metrics-server: ":9965"` to the ConfigMap, restart the agent with `kubectl -n kube-system rollout restart daemonset/cilium` and read the metrics through the Kubernetes API.
- Change `hubble-event-buffer-capacity` to `16383` and watch `Max Flows` change.

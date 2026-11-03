# Overview: Using The Hubble Command Line (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay (Deployment `hubble-relay` and Service `hubble-relay` in `kube-system`).
- In `starfleet`: the `probe` Deployment and Service (`go-httpbin` on port 8080) and the client pod `shuttle`.
- In `outpost`: the client pod `drifter`.
- `kubectl` already points at the cluster as the cluster administrator.
- The Hubble command-line tool runs inside the Cilium agent pod: `kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe`.
- The policy `probe-ingress` and the pod `rogue`, which produces dropped flows every 5 seconds.
- The Hubble CLI is not installed on your machine. Run it inside the agent pod, or install it and connect to Relay with a port-forward.

## Things to try

- Run `hubble status` and `hubble list nodes` in the agent pod.
- Run `hubble observe --last 20 -o compact`, then the same command with `-o json` and `-o dict`.
- Filter with `--verdict DROPPED`, `--from-pod outpost/rogue`, `--to-port 8080` and `--since 2m`.
- Port-forward Relay with `kubectl -n kube-system port-forward service/hubble-relay 4245:80` and run `hubble status --server localhost:4245` if you installed the CLI on your machine.

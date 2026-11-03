# Overview: Hubble Flow Export (Playground)

This is a playground, not a lab. It starts a fresh kind cluster with Cilium, Hubble and Hubble Relay, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is in the box

- A single-node kind cluster running Kubernetes 1.35, with Cilium 1.20.2, Hubble and Hubble Relay.
- In `starfleet`: the `probe` Deployment and Service on port 8080 and the client pod `shuttle`.
- In `outpost`: the client pods `drifter` and `rogue`. The policy `probe-ingress` drops their requests, and `rogue` sends one every 5 seconds.
- `kubectl` points at the cluster as the cluster administrator.
- Flow export is off.

## Things to try

- Read the export keys: `kubectl -n kube-system get configmap cilium-config -o yaml | grep hubble-export`.
- Set `hubble-export-file-path` to `/var/run/cilium/hubble/events.log`, restart the agent and read the file with `kubectl -n kube-system exec ds/cilium -c cilium-agent -- tail -n 3 /var/run/cilium/hubble/events.log`.
- Add `hubble-export-allowlist` with the value `{"verdict":["DROPPED"]}` and restart the agent again.

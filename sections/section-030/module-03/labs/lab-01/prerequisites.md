# Prerequisites

- The `astrona` command-line tool, installed and working.
- A container engine that kind can use (Podman or Docker) with about 4 GiB of free memory.
- `kubectl`, `helm` and `jq`.
- You know what a Cilium network policy and a Hubble flow are.

The lab starts a single-node kind cluster (Kubernetes 1.35) without a default network plugin. The setup script installs Cilium 1.20.2 with Hubble and Hubble Relay, then creates the example workloads in `starfleet` and `outpost`.

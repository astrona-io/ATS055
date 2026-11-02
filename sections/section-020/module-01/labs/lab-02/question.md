---
draft: true
exam_objectives:
- Enabling Layer 7 Protocol Visibility
---
# Record A Real HTTP Flow From Hubble Relay

Observe an HTTP response through Relay and verify it against the live flow window.

## Starting state

Cilium manages the private two-node cluster. Hubble Relay and the BGP control plane are enabled. The probe and two clients are healthy; no learner policy or evidence report exists. This baseline uses kube-proxy and tunnelling.

Use a host shell with the private kubeconfig for this independent kind environment. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-055-lab-020-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-055-lab-020-01-02" || exit 1
node_name="astro-ats-055-lab-020-01-02-control-plane"
worker_name="astro-ats-055-lab-020-01-02-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Required result

Apply the HTTP policy, generate GET /public and record an actual successful response flow. Use the local Hubble CLI and a temporary loopback-only port-forward. Store the complete Flow object under flow in the evidence report; the grader checks it still exists in the two-minute Relay window. Observe both L7 metadata and policy verdicts. Refresh the evidence before submitting if the window has expired.

## Verify The Result

The grader checks the required object fields and actual observations. Wait for controller convergence before submitting. Preserve the task's namespace, workload names and unrelated components.

#!/usr/bin/env bash
# Check: The agent runs with a flow buffer of 8191 flows
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }
kubectl -n kube-system rollout status daemonset/cilium --timeout=120s >/dev/null || { echo "FAIL: agent DaemonSet is not ready"; exit 1; }
status="$(hubble status 2>&1)"
echo "$status" | grep -q "/8191" || { echo "FAIL: hubble status does not show a maximum of 8191 flows"; echo "$status"; exit 1; }
echo "PASS: maximum flows is 8191"

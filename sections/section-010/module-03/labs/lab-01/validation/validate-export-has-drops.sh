#!/usr/bin/env bash
# Check: the export file in the agent pod contains dropped flows
set -uo pipefail
sleep 8
count="$(kubectl -n kube-system exec ds/cilium -c cilium-agent -- grep -c '"verdict":"DROPPED"' /var/run/cilium/hubble/events.log 2>/dev/null || true)"
[ "${count:-0}" -ge 1 ] || { echo "FAIL: no dropped flow in the export file"; exit 1; }
echo "PASS: the export file has dropped flows"

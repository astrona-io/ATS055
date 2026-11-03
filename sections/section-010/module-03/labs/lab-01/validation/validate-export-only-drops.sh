#!/usr/bin/env bash
# Check: the export file holds no forwarded flows
set -uo pipefail
count="$(kubectl -n kube-system exec ds/cilium -c cilium-agent -- grep -c '"verdict":"FORWARDED"' /var/run/cilium/hubble/events.log 2>/dev/null || true)"
[ "${count:-0}" -eq 0 ] || { echo "FAIL: the export file has forwarded flows"; exit 1; }
echo "PASS: only dropped flows are exported"

#!/usr/bin/env bash
# Check: Hubble holds a dropped flow from drifter to probe
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }

count="$(hubble observe --from-pod outpost/drifter --to-pod starfleet/probe --verdict DROPPED --last 2000 -o compact 2>/dev/null | grep -c -E 'DROPPED' || true)"
if [ "${count:-0}" -lt 1 ]; then
  echo "FAIL: no Hubble flow matched DROPPED (filters: --from-pod outpost/drifter --to-pod starfleet/probe --verdict DROPPED --last 2000)"
  exit 1
fi
echo "PASS: found $count matching flows"

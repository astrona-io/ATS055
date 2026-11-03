#!/usr/bin/env bash
# Check: Hubble holds a forwarded flow from shuttle to probe
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }

count="$(hubble observe --from-pod starfleet/shuttle --to-pod starfleet/probe --verdict FORWARDED --last 2000 -o compact 2>/dev/null | grep -c -E 'FORWARDED' || true)"
if [ "${count:-0}" -lt 1 ]; then
  echo "FAIL: no Hubble flow matched FORWARDED (filters: --from-pod starfleet/shuttle --to-pod starfleet/probe --verdict FORWARDED --last 2000)"
  exit 1
fi
echo "PASS: found $count matching flows"

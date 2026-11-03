#!/usr/bin/env bash
# Check: Requests from rogue to the probe are now forwarded
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }
sleep 10
count="$(hubble observe --from-pod outpost/rogue --to-pod starfleet/probe --verdict FORWARDED --since 60s -o compact 2>/dev/null | grep -c FORWARDED || true)"
[ "${count:-0}" -ge 1 ] || { echo "FAIL: no forwarded flow from rogue in the last 60 seconds"; exit 1; }
echo "PASS: rogue is forwarded"

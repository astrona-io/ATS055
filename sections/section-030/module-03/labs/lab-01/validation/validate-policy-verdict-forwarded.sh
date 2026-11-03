#!/usr/bin/env bash
# Check: Hubble shows a forwarded policy verdict for cadet
set -uo pipefail
kubectl -n starfleet exec cadet -- curl -s -o /dev/null -m 5 http://probe.starfleet:8080/get 2>/dev/null || true
sleep 3
flows="$(kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble observe --type policy-verdict --from-pod starfleet/cadet --last 50 -o compact 2>/dev/null)"
echo "$flows" | grep -q FORWARDED || { echo "FAIL: no forwarded policy verdict for cadet"; exit 1; }
echo "PASS: a forwarded policy verdict exists for cadet"

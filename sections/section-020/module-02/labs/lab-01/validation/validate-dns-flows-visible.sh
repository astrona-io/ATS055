#!/usr/bin/env bash
# Check: Hubble shows a DNS query from shuttle for the probe name
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
http_code starfleet shuttle http://probe.starfleet:8080/get >/dev/null
sleep 3
hubble observe --type l7 --protocol dns --from-pod starfleet/shuttle --last 500 -o compact 2>/dev/null | grep -q "probe.starfleet" \
  || { echo "FAIL: no DNS flow for probe.starfleet"; exit 1; }
echo "PASS: DNS query flow is visible"

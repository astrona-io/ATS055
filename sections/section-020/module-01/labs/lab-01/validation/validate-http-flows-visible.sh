#!/usr/bin/env bash
# Check: Hubble shows the HTTP request GET /get as forwarded and /headers as dropped
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
http_code starfleet shuttle http://probe.starfleet:8080/get >/dev/null
http_code starfleet shuttle http://probe.starfleet:8080/headers >/dev/null
sleep 3
flows="$(hubble observe --type l7 --protocol http --from-pod starfleet/shuttle --last 500 -o compact 2>/dev/null)"
echo "$flows" | grep FORWARDED | grep -q "/get" || { echo "FAIL: no forwarded HTTP flow for /get"; exit 1; }
echo "$flows" | grep DROPPED | grep -q "/headers" || { echo "FAIL: no dropped HTTP flow for /headers"; exit 1; }
echo "PASS: HTTP flows with both verdicts are visible"

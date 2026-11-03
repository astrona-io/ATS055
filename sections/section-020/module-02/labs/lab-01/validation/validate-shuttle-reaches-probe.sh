#!/usr/bin/env bash
# Check: shuttle still reaches the probe by name
set -uo pipefail
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
[ "$(http_code starfleet shuttle http://probe.starfleet:8080/get)" = "200" ] || { echo "FAIL: shuttle cannot reach the probe by name"; exit 1; }
echo "PASS: shuttle reaches the probe"

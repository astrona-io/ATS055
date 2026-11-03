#!/usr/bin/env bash
# Check: GET /get from shuttle returns 200, GET /headers returns 403, drifter is refused
set -uo pipefail
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
fail=0
[ "$(http_code starfleet shuttle http://probe.starfleet:8080/get)" = "200" ] || { echo "FAIL: shuttle GET /get is not 200"; fail=1; }
[ "$(http_code starfleet shuttle http://probe.starfleet:8080/headers)" = "403" ] || { echo "FAIL: shuttle GET /headers is not 403"; fail=1; }
[ "$(http_code outpost drifter http://probe.starfleet:8080/get)" != "200" ] || { echo "FAIL: drifter reached the probe"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: allowed and denied requests behave as expected"
exit "$fail"

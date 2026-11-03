#!/usr/bin/env bash
# Check: cadet in starfleet reaches the probe and shuttle still does
set -uo pipefail
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
fail=0
[ "$(http_code starfleet cadet http://probe.starfleet:8080/get)" = "200" ] || { echo "FAIL: cadet does not reach the probe"; fail=1; }
[ "$(http_code starfleet shuttle http://probe.starfleet:8080/get)" = "200" ] || { echo "FAIL: shuttle does not reach the probe"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: cadet and shuttle reach the probe"
exit "$fail"

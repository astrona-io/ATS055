#!/usr/bin/env bash
# Check: drifter and rogue in outpost are still refused
set -uo pipefail
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
fail=0
for pod in drifter rogue; do
  [ "$(http_code outpost "$pod" http://probe.starfleet:8080/get)" != "200" ] || { echo "FAIL: $pod reaches the probe"; fail=1; }
done
[ "$fail" -eq 0 ] && echo "PASS: drifter and rogue are still refused"
exit "$fail"

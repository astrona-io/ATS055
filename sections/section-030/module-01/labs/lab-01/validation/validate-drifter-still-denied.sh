#!/usr/bin/env bash
# Check: drifter is still refused
set -uo pipefail
code="$(kubectl -n outpost exec drifter -- curl -s -o /dev/null -m 5 -w "%{http_code}" http://probe.starfleet:8080/get 2>/dev/null || true)"
[ "$code" != "200" ] || { echo "FAIL: drifter reaches the probe"; exit 1; }
echo "PASS: drifter is still refused"

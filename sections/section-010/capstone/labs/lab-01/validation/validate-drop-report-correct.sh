#!/usr/bin/env bash
# Check: drop-report names the right source, destination and port
set -uo pipefail
fail=0
value() { kubectl -n starfleet get configmap drop-report -o "jsonpath={.data.$1}" 2>/dev/null || true; }
expect() {
  local actual
  actual="$(value "$1")"
  if [ "$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')" != "$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')" ]; then
    echo "FAIL: ConfigMap drop-report key $1 is '$actual', expected '$2'"
    fail=1
  fi
}
expect "source" "outpost/rogue"
expect "destination" "starfleet/probe"
expect "port" "8080"
[ "$fail" -eq 0 ] && echo "PASS: drop-report holds the expected values"
exit "$fail"

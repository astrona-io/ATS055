#!/usr/bin/env bash
# Check: cli-report names the dropped source, destination, port and verdict
set -uo pipefail
fail=0
value() { kubectl -n starfleet get configmap cli-report -o "jsonpath={.data.$1}" 2>/dev/null || true; }
expect() {
  local actual
  actual="$(value "$1")"
  if [ "$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')" != "$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')" ]; then
    echo "FAIL: ConfigMap cli-report key $1 is '$actual', expected '$2'"
    fail=1
  fi
}
expect "dropped-source" "outpost/rogue"
expect "destination" "starfleet/probe"
expect "destination-port" "8080"
expect "verdict" "DROPPED"
[ "$fail" -eq 0 ] && echo "PASS: cli-report holds the expected values"
exit "$fail"

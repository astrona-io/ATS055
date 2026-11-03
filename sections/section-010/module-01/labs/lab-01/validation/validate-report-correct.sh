#!/usr/bin/env bash
# Check: The report names the right sources and port
set -uo pipefail
fail=0
value() { kubectl -n starfleet get configmap flow-report -o "jsonpath={.data.$1}" 2>/dev/null || true; }
expect() {
  local actual
  actual="$(value "$1")"
  if [ "$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')" != "$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')" ]; then
    echo "FAIL: ConfigMap flow-report key $1 is '$actual', expected '$2'"
    fail=1
  fi
}
expect "forwarded-source" "starfleet/shuttle"
expect "dropped-source" "outpost/drifter"
expect "dropped-destination-port" "8080"
[ "$fail" -eq 0 ] && echo "PASS: flow-report holds the expected values"
exit "$fail"

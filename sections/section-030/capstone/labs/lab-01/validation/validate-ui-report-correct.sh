#!/usr/bin/env bash
# Check: ui-report lists the dropped edge and the namespaces of the map
set -uo pipefail
fail=0
value() { kubectl -n starfleet get configmap ui-report -o "jsonpath={.data.$1}" 2>/dev/null || true; }
expect() {
  local actual
  actual="$(value "$1")"
  if [ "$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')" != "$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')" ]; then
    echo "FAIL: ConfigMap ui-report key $1 is '$actual', expected '$2'"
    fail=1
  fi
}
expect "dropped-edge" "outpost/rogue->starfleet/probe"
expect "namespaces" "outpost,starfleet"
[ "$fail" -eq 0 ] && echo "PASS: ui-report holds the expected values"
exit "$fail"

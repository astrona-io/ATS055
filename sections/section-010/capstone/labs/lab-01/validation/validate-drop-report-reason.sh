#!/usr/bin/env bash
# Check: drop-report gives the policy-denied reason
set -uo pipefail
reason="$(kubectl -n starfleet get configmap drop-report -o jsonpath='{.data.reason}' 2>/dev/null | tr '[:upper:]_' '[:lower:] ')"
[ "$reason" = "policy denied" ] || { echo "FAIL: reason is '$reason'"; exit 1; }
echo "PASS: reason recorded"

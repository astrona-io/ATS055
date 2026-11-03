#!/usr/bin/env bash
# Check: The probe policy has an HTTP rule for GET /get from shuttle only
set -uo pipefail
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o json | jq -e '
  [.spec.ingress[] | select(.fromEndpoints[].matchLabels.app == "shuttle") | .toPorts[].rules.http[]? | select(.method == "GET" and .path == "/get")] | length >= 1' >/dev/null \
  || { echo "FAIL: no http rule with method GET and path /get for shuttle"; exit 1; }
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o json | jq -e '[.spec.ingress[].fromEndpoints[].matchLabels.app] | all(. == "shuttle")' >/dev/null \
  || { echo "FAIL: another source is allowed"; exit 1; }
echo "PASS: HTTP rule present"

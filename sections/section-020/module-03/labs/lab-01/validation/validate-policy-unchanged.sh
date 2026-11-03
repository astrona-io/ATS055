#!/usr/bin/env bash
# Check: the probe policy keeps its GET /get rule and its single source
set -uo pipefail
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o json | jq -e '
  [.spec.ingress[].toPorts[].rules.http[]? | select(.method == "GET" and .path == "/get")] | length == 1' >/dev/null \
  || { echo "FAIL: the GET /get rule changed"; exit 1; }
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o json | jq -e '[.spec.ingress[].fromEndpoints[].matchLabels.app] | all(. == "shuttle")' >/dev/null \
  || { echo "FAIL: another source is allowed"; exit 1; }
echo "PASS: policy unchanged"

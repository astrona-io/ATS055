#!/usr/bin/env bash
# Check: The probe-ingress policy still exists and still allows only shuttle
set -uo pipefail
kubectl -n starfleet get ciliumnetworkpolicy probe-ingress -o json | jq -e '[.spec.ingress[].fromEndpoints[].matchLabels.app] == ["shuttle"]' >/dev/null || { echo "FAIL: probe-ingress was changed"; exit 1; }
echo "PASS: probe-ingress is unchanged"

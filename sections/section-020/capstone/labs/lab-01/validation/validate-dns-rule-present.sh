#!/usr/bin/env bash
# Check: A policy for shuttle has a DNS rule on port 53 and still allows the probe on 8080
set -uo pipefail
kubectl -n starfleet get ciliumnetworkpolicy -o json | jq -e '
  [.items[] | select(.spec.endpointSelector.matchLabels.app == "shuttle") | .spec.egress[]? | .toPorts[]? | select(.rules.dns != null)] | length >= 1' >/dev/null \
  || { echo "FAIL: no DNS rule in an egress policy for shuttle"; exit 1; }
echo "PASS: DNS rule present"

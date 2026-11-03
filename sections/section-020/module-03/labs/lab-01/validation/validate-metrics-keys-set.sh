#!/usr/bin/env bash
# Check: cilium-config enables httpV2 metrics on port 9965
set -uo pipefail
value() { kubectl -n kube-system get configmap cilium-config -o "jsonpath={.data.$1}"; }
fail=0
echo " $(value hubble-metrics | tr '\n' ' ') " | grep -Eq ' httpV2[: ]' || { echo "FAIL: hubble-metrics does not list httpV2"; fail=1; }
[ "$(value hubble-metrics-server)" = ":9965" ] || { echo "FAIL: hubble-metrics-server is not :9965"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: httpV2 metrics are configured"
exit "$fail"

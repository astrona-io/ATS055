#!/usr/bin/env bash
# Check: Drop and flow metrics on :9965 and a buffer of 16383 are active in the agent
set -uo pipefail
hubble() { kubectl -n kube-system exec ds/cilium -c cilium-agent -- hubble "$@"; }
value() { kubectl -n kube-system get configmap cilium-config -o "jsonpath={.data.$1}"; }
fail=0
metrics=" $(value hubble-metrics | tr '\n' ' ') "
for name in drop flow; do echo "$metrics" | grep -q " $name " || { echo "FAIL: $name metric not listed"; fail=1; }; done
[ "$(value hubble-metrics-server)" = ":9965" ] || { echo "FAIL: metrics server is not :9965"; fail=1; }
kubectl -n kube-system rollout status daemonset/cilium --timeout=120s >/dev/null || { echo "FAIL: agent not ready"; fail=1; }
hubble status 2>&1 | grep -q "/16383" || { echo "FAIL: maximum flows is not 16383"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: settings are active"
exit "$fail"

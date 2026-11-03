#!/usr/bin/env bash
# Check: cilium-config enables drop and flow metrics on port 9965 and a buffer of 8191
set -uo pipefail
value() { kubectl -n kube-system get configmap cilium-config -o "jsonpath={.data.$1}"; }
metrics="$(value hubble-metrics)"
fail=0
for name in drop flow; do
  echo " $metrics " | tr '\n' ' ' | grep -q " $name " || { echo "FAIL: hubble-metrics does not list $name"; fail=1; }
done
[ "$(value hubble-metrics-server)" = ":9965" ] || { echo "FAIL: hubble-metrics-server is not :9965"; fail=1; }
[ "$(value hubble-event-buffer-capacity)" = "8191" ] || { echo "FAIL: hubble-event-buffer-capacity is not 8191"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: ConfigMap keys are set"
exit "$fail"

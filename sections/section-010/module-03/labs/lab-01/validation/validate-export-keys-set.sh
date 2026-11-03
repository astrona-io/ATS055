#!/usr/bin/env bash
# Check: cilium-config sets the export file path and an allow list for dropped flows
set -uo pipefail
value() { kubectl -n kube-system get configmap cilium-config -o "jsonpath={.data.$1}"; }
fail=0
[ "$(value hubble-export-file-path)" = "/var/run/cilium/hubble/events.log" ] || { echo "FAIL: hubble-export-file-path is not /var/run/cilium/hubble/events.log"; fail=1; }
value hubble-export-allowlist | jq -e '.verdict | index("DROPPED")' >/dev/null 2>&1 || { echo "FAIL: hubble-export-allowlist does not select the DROPPED verdict"; fail=1; }
[ "$fail" -eq 0 ] && echo "PASS: export keys are set"
exit "$fail"

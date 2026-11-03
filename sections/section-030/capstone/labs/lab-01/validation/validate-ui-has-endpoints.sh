#!/usr/bin/env bash
# Check: The hubble-ui Deployment is ready and the Service has a ready endpoint
set -uo pipefail
kubectl -n kube-system rollout status deployment/hubble-ui --timeout=120s >/dev/null || { echo "FAIL: hubble-ui Deployment is not ready"; exit 1; }
ready="$(kubectl -n kube-system get endpointslices -l kubernetes.io/service-name=hubble-ui -o jsonpath='{.items[*].endpoints[?(@.conditions.ready==true)].addresses[0]}')"
[ -n "$ready" ] || { echo "FAIL: Service hubble-ui has no ready endpoint"; exit 1; }
echo "PASS: hubble-ui has a ready endpoint"

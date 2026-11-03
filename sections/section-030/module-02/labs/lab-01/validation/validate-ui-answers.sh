#!/usr/bin/env bash
# Check: The Hubble UI answers an HTTP request through the Service
set -uo pipefail
page="$(kubectl get --raw /api/v1/namespaces/kube-system/services/hubble-ui:80/proxy/ 2>/dev/null)"
echo "$page" | grep -qi '<html' || { echo "FAIL: the UI did not return an HTML page"; exit 1; }
echo "PASS: the UI answers"

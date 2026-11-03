#!/usr/bin/env bash
# Check: The agent exposes hubble_drop_total
set -uo pipefail
pod="$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')"
sleep 8
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" 2>/dev/null | grep -q '^hubble_drop_total' || { echo "FAIL: hubble_drop_total is not exposed"; exit 1; }
echo "PASS: hubble_drop_total is exposed"

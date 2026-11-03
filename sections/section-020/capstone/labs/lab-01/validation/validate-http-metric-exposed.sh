#!/usr/bin/env bash
# Check: The agent exposes hubble_http_requests_total
set -uo pipefail
http_code() { kubectl -n "$1" exec "$2" -- curl -s -o /dev/null -m 5 -w "%{http_code}" "$3" 2>/dev/null || true; }
http_code starfleet shuttle http://probe.starfleet:8080/get >/dev/null
sleep 8
pod="$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')"
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" 2>/dev/null | grep -q '^hubble_http_requests_total' || { echo "FAIL: hubble_http_requests_total is not exposed"; exit 1; }
echo "PASS: HTTP metric is exposed"

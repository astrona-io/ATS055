#!/usr/bin/env bash
# Check: the agent exposes hubble_http_requests_total after requests from shuttle
set -uo pipefail
for attempt in 1 2 3; do
  kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -m 5 http://probe.starfleet:8080/get 2>/dev/null || true
done
sleep 5
pod="$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')"
kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" 2>/dev/null | grep -q '^hubble_http_requests_total' \
  || { echo "FAIL: hubble_http_requests_total is not exposed"; exit 1; }
echo "PASS: the HTTP request counter is exposed"

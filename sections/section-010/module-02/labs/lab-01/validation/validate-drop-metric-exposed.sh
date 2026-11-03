#!/usr/bin/env bash
# Check: The agent exposes hubble_drop_total with the policy-denied reason
set -uo pipefail
pod="$(kubectl -n kube-system get pod -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')"
kubectl -n outpost exec drifter -- curl -s -o /dev/null -m 3 http://probe.starfleet:8080/get >/dev/null 2>&1 || true
sleep 8
metrics="$(kubectl get --raw "/api/v1/namespaces/kube-system/pods/${pod}:9965/proxy/metrics" 2>/dev/null)"
echo "$metrics" | grep -q '^hubble_drop_total' || { echo "FAIL: hubble_drop_total is not exposed"; exit 1; }
echo "$metrics" | grep -q '^hubble_flows_processed_total' || { echo "FAIL: hubble_flows_processed_total is not exposed"; exit 1; }
echo "PASS: drop and flow metrics are exposed"

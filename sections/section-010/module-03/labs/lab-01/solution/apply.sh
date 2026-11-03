#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-export-file-path":"/var/run/cilium/hubble/events.log","hubble-export-allowlist":"{\"verdict\":[\"DROPPED\"]}"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s

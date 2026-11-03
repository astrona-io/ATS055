#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n kube-system scale deployment/hubble-ui --replicas=1
kubectl -n kube-system patch service hubble-ui --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"k8s-app":"hubble-ui"}}]'
kubectl -n kube-system rollout status deployment/hubble-ui --timeout=300s
kubectl -n starfleet create configmap ui-report --from-literal=dropped-edge='outpost/rogue->starfleet/probe' --from-literal=namespaces=outpost,starfleet --dry-run=client -o yaml | kubectl apply -f -

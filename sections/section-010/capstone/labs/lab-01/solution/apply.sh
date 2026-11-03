#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"drop flow","hubble-metrics-server":":9965","hubble-event-buffer-capacity":"16383"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
sleep 15
kubectl -n starfleet create configmap drop-report --from-literal=source=outpost/rogue --from-literal=destination=starfleet/probe --from-literal=port=8080 --from-literal='reason=Policy denied' --dry-run=client -o yaml | kubectl apply -f -

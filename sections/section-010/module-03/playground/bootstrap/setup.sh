#!/usr/bin/env bash
# Starting state for ats-055-playground-010-03. UNTESTED: written from the Cilium chart and
# documentation, not run. It installs Cilium, then the example workloads.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-055-playground-010-03" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
environment_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
chart_path="$(mktemp)"
trap 'rm -f "$chart_path"' EXIT
curl --fail --silent --show-error --location --max-time 120 https://helm.cilium.io/cilium-1.20.2.tgz -o "$chart_path"
echo "b2afd87b7f75f875f92a14559f14f59b7babbb479d968e3fd625a20bf30ec20e  $chart_path" | shasum -a 256 -c - || { echo "Cilium chart checksum differs" >&2; exit 1; }
helm upgrade --install cilium "$chart_path" --namespace kube-system \
  --set ipam.mode=kubernetes \
  --set operator.replicas=1 \
  --set hubble.relay.enabled=true \
  --wait --timeout 300s
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
kubectl -n kube-system rollout status deployment/hubble-relay --timeout=300s
kubectl wait --for=condition=Ready nodes --all --timeout=180s
kubectl apply -f "$environment_directory/bootstrap/manifests/start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/rogue --timeout=120s
echo "[environment] Ready."

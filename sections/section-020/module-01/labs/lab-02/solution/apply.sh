#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-055-lab-020-01-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
node_name="astro-ats-055-lab-020-01-02-control-plane"
worker_name="astro-ats-055-lab-020-01-02-worker"

kubectl apply -f "$solution_directory/ciliumnetworkpolicy-allow-shuttle.yaml"
kubectl -n starfleet exec shuttle -- python -c 'import urllib.request; print(urllib.request.urlopen('"'"'http://probe:8080/public'"'"',timeout=4).read().decode())'
sleep 3
python3 "$solution_directory/record-flow.py"

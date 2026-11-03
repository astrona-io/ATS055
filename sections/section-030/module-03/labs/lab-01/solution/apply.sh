#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "$solution_directory/probe-ingress-cadet.yaml" <<'YAML'
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: probe-ingress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: probe
  ingress:
  - fromEndpoints:
    - matchLabels:
        app: shuttle
    - matchLabels:
        app: cadet
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
YAML
kubectl apply -f "$solution_directory/probe-ingress-cadet.yaml"
sleep 10

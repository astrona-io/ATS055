#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n starfleet create configmap cli-report --from-literal=dropped-source=outpost/rogue --from-literal=destination=starfleet/probe --from-literal=destination-port=8080 --from-literal=verdict=DROPPED --dry-run=client -o yaml | kubectl apply -f -
cat > "$solution_directory/probe-ingress-rogue.yaml" <<'YAML'
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
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
  - fromEndpoints:
    - matchLabels:
        app: rogue
        io.kubernetes.pod.namespace: outpost
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
YAML
kubectl apply -f "$solution_directory/probe-ingress-rogue.yaml"
sleep 15

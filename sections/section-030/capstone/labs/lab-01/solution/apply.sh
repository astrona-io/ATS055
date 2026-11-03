#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n kube-system scale deployment/hubble-ui --replicas=1
kubectl -n kube-system patch service hubble-ui --type=json -p '[{"op":"replace","path":"/spec/selector","value":{"k8s-app":"hubble-ui"}}]'
kubectl -n kube-system rollout status deployment/hubble-ui --timeout=300s
kubectl -n starfleet create configmap cli-report --from-literal=dropped-source=outpost/rogue --from-literal=destination=starfleet/probe --from-literal=destination-port=8080 --from-literal=verdict=DROPPED --dry-run=client -o yaml | kubectl apply -f -
kubectl -n starfleet create configmap ui-report --from-literal=dropped-edge='outpost/rogue->starfleet/probe' --from-literal=namespaces=outpost,starfleet --dry-run=client -o yaml | kubectl apply -f -
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

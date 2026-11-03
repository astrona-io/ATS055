#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cat > "$solution_directory/probe-ingress-http.yaml" <<'YAML'
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
      rules:
        http:
        - method: GET
          path: /get
YAML
cat > "$solution_directory/shuttle-egress.yaml" <<'YAML'
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: shuttle-egress
  namespace: starfleet
spec:
  endpointSelector:
    matchLabels:
      app: shuttle
  egress:
  - toEndpoints:
    - matchLabels:
        io.kubernetes.pod.namespace: kube-system
        k8s-app: kube-dns
    toPorts:
    - ports:
      - port: "53"
        protocol: UDP
      - port: "53"
        protocol: TCP
      rules:
        dns:
        - matchPattern: "*"
  - toEndpoints:
    - matchLabels:
        app: probe
    toPorts:
    - ports:
      - port: "8080"
        protocol: TCP
YAML
kubectl apply -f "$solution_directory/probe-ingress-http.yaml"
kubectl apply -f "$solution_directory/shuttle-egress.yaml"
kubectl -n kube-system patch configmap cilium-config --type merge -p '{"data":{"hubble-metrics":"httpV2","hubble-metrics-server":":9965"}}'
kubectl -n kube-system rollout restart daemonset/cilium
kubectl -n kube-system rollout status daemonset/cilium --timeout=300s
sleep 15
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/get
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null http://probe.starfleet:8080/headers || true

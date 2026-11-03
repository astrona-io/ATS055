#!/usr/bin/env bash
# Reference solution, applied only by `astrona test`.
set -euo pipefail
solution_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl -n starfleet exec shuttle -- curl -s -o /dev/null -m 5 -w "%{http_code}\n" http://probe.starfleet:8080/get
kubectl -n outpost exec drifter -- curl -s -o /dev/null -m 5 -w "%{http_code}\n" http://probe.starfleet:8080/get || true
kubectl -n starfleet create configmap flow-report --from-literal=forwarded-source=starfleet/shuttle --from-literal=dropped-source=outpost/drifter --from-literal='drop-reason=Policy denied' --from-literal=dropped-destination-port=8080 --dry-run=client -o yaml | kubectl apply -f -

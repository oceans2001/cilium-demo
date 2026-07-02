#!/usr/bin/env bash
set -euo pipefail

FRONTEND=$(kubectl get pod -n cilium-demo -l app=frontend -o jsonpath='{.items[0].metadata.name}')

echo "==> ALLOWED: GET /get"
kubectl exec -n cilium-demo "$FRONTEND" -- curl -s -o /dev/null -w "HTTP %{http_code}\n" http://backend/get

echo ""
echo "==> ALLOWED: GET /headers"
kubectl exec -n cilium-demo "$FRONTEND" -- curl -s -o /dev/null -w "HTTP %{http_code}\n" http://backend/headers

echo ""
echo "==> BLOCKED: POST /post (expect 403 — dropped by L7 policy)"
kubectl exec -n cilium-demo "$FRONTEND" -- curl -s -o /dev/null -w "HTTP %{http_code}\n" -X POST http://backend/post || true

echo ""
echo "==> Check Hubble UI at http://localhost:12000 to see flows and drops"

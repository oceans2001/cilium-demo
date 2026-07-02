#!/usr/bin/env bash
set -euo pipefail

CILIUM_POD=$(kubectl get pod -n kube-system -l k8s-app=cilium -o jsonpath='{.items[0].metadata.name}')

echo "==> eBPF programs loaded by Cilium:"
kubectl exec -n kube-system "$CILIUM_POD" -- bpftool prog list | grep -E "sched_cls|xdp" | head -20

echo ""
echo "==> Cilium endpoint list:"
kubectl exec -n kube-system "$CILIUM_POD" -- cilium endpoint list

echo ""
echo "==> Active network policies:"
kubectl exec -n kube-system "$CILIUM_POD" -- cilium policy get

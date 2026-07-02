.PHONY: cluster cilium app policies hubble demo-traffic demo-ebpf demo-endpoints clean

cluster:
	kind create cluster --config=kind-config.yaml

cilium:
	helm repo add cilium https://helm.cilium.io/
	helm repo update
	helm install cilium cilium/cilium \
		--namespace kube-system \
		--values cilium-values.yaml
	kubectl rollout status daemonset/cilium -n kube-system --timeout=120s

app:
	kubectl apply -f manifests/demo-app/namespace.yaml
	kubectl apply -f manifests/demo-app/backend.yaml
	kubectl apply -f manifests/demo-app/frontend.yaml
	kubectl rollout status deployment/backend -n cilium-demo --timeout=60s
	kubectl rollout status deployment/frontend -n cilium-demo --timeout=60s

policies:
	kubectl apply -f manifests/network-policies/default-deny.yaml
	kubectl apply -f manifests/network-policies/l7-http-policy.yaml

hubble:
	kubectl port-forward -n kube-system svc/hubble-ui 12000:80

demo-traffic:
	./scripts/traffic.sh

demo-ebpf:
	./scripts/ebpf.sh

demo-endpoints:
	kubectl get cep -n cilium-demo

clean:
	kind delete cluster --name cilium-demo

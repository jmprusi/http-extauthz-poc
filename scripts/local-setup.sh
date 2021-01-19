#!/bin/bash
set -euo pipefail

export EXTAUTHZ_NAMESPACE="extauthz"
export KIND_CLUSTER_NAME="extauthz-poc"

run_kubectl () {
    kubectl -n "${EXTAUTHZ_NAMESPACE}" "${@}"
}

kind delete cluster
kind create cluster

echo "Creating namespace"
kubectl create namespace "${EXTAUTHZ_NAMESPACE}"

echo "Deploying HTTPBin"
run_kubectl apply -f ./httpbin/httpbin.yaml

echo "Deploying Envoy proxy"
run_kubectl create configmap envoy-config --from-file=config=./envoy/envoy-config.yaml
run_kubectl apply -f ./envoy/envoy.yaml

echo "Deploying OPA"
run_kubectl create configmap opa-config --from-file=opa-config=./opa/opa.config --from-file=authz=./opa/authz.rego
run_kubectl apply -f ./opa/opa.yaml

echo "Deploying Openresty"
run_kubectl create configmap openresty-config --from-file=authz=./openresty/example-authz.conf
run_kubectl apply -f ./openresty/openresty.yaml

echo "Wait for all deployments to be up"
run_kubectl wait --timeout=300s --for=condition=Available deployments --all

echo
echo "Now you can export the envoy service by doing:"
echo "kubectl port-forward --namespace extauthz deployment/envoy 8080:8080"
echo "after that, you can curl -H \"Host: myhost.com\" localhost:8000"
echo

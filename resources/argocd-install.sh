#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

ARGO_OPERATOR_VERSION="v0.6.0"
ARGO_OPERATOR_VERSION="ba14854"
echo "Install ArgoCD Operator $ARGO_OPERATOR_VERSION"

waitfor() {
  xtrace=$(set +o|grep xtrace); set +x
  local ns=${1?namespace is required}; shift
  local type=${1?type is required}; shift

  echo "Waiting for $type $*"
  # wait for resource to exist. See: https://github.com/kubernetes/kubernetes/issues/83242
  until kubectl -n "$ns" get "$type" "$@" -o=jsonpath='{.items[0].metadata.name}' >/dev/null 2>&1; do
    echo "Waiting for $type $*"
    sleep 1
  done
  eval "$xtrace"
}

echo "HACK: set PodPolicy to baseline for namespace olm"
echo "Watch issue https://github.com/argoproj-labs/argocd-operator/issues/945"
kubectl patch namespaces olm --type='json' -p='[{"op": "replace", "path": "/metadata/labels/pod-security.kubernetes.io~1enforce", "value":"baseline"}]'

GITHUB_URL="https://raw.githubusercontent.com/argoproj-labs/argocd-operator/$ARGO_OPERATOR_VERSION"
kubectl apply -n olm -f "$GITHUB_URL/deploy/catalog_source.yaml"
kubectl get catalogsources -n olm argocd-catalog
kubectl get pods -n olm -l olm.catalogSource=argocd-catalog

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f "$GITHUB_URL/deploy/operator_group.yaml"
kubectl get operatorgroups -n argocd
kubectl apply -n argocd -f "$GITHUB_URL/deploy/subscription.yaml"
kubectl get subscriptions -n argocd argocd-operator
waitfor argocd installplan -l "operators.coreos.com/argocd-operator.argocd="
kubectl wait installplans -n argocd --for=condition=Installed -l "operators.coreos.com/argocd-operator.argocd=" --timeout=120s

echo "Wait for ArgoCD Operator to be ready"
kubectl rollout status deployment/argocd-operator-controller-manager --timeout=120s -n argocd
kubectl get pods -n argocd -l name=argocd-operator

echo "Install ArgoCD $ARGO_OPERATOR_VERSION"
kubectl apply -n argocd -f "$GITHUB_URL/examples/argocd-basic.yaml"

# !!! TODO look for error below
kubectl describe -n olm catalogsources.operators.coreos.com argocd-catalog

#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

ARGO_OPERATOR_VERSION="v0.10.0"

# Get lates release version with below command:
# ARGO_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
ARGO_VERSION="v2.11.2"
GITHUB_URL="https://raw.githubusercontent.com/argoproj-labs/argocd-operator/$ARGO_OPERATOR_VERSION"

OPERATOR_NAMESPACE="operators"

timeout=240
timeout_sec="${timeout}s"

wait_for_exist() {
  xtrace=$(set +o|grep xtrace); set +x
  local ns=${1?namespace is required}; shift
  local type=${1?type is required}; shift
  local max_wait_secs=${1?max_wait_secs is required}; shift
  local interval_secs=2
  local start_time=$(date +%s)
  while true; do
    echo "Waiting for $type $*"

    current_time=$(date +%s)
    if (( (current_time - start_time) > max_wait_secs ))
    then
      echo "Waited for pods in namespace \"$ns\" (selected using $@) to exist for $max_wait_secs seconds without luck. Returning with error."
      return 1
    fi

    if kubectl -n "$ns" get "$type" "$@" -o=jsonpath='{.items[0].metadata.name}' >/dev/null 2>&1
    then
      break
    else
      sleep $interval_secs
    fi
  done
  eval "$xtrace"
}

echo "Install ArgoCD Operator $ARGO_OPERATOR_VERSION"
# Based on https://argocd-operator.readthedocs.io/en/latest/install/olm/#operator-install

cat > /tmp/subscription.yaml <<SUBSCRIPTION
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: argocd-operator
  namespace: "$OPERATOR_NAMESPACE"
spec:
  channel: alpha
  config:
   env:
    - name: ARGOCD_CLUSTER_CONFIG_NAMESPACES
      value: argocd
  name: argocd-operator
  source: operatorhubio-catalog
  sourceNamespace: olm
SUBSCRIPTION
kubectl apply -f "/tmp/subscription.yaml"

wait_for_exist "$OPERATOR_NAMESPACE" installplans "$timeout"
kubectl wait installplans -n "$OPERATOR_NAMESPACE" --for=condition=Installed -l "operators.coreos.com/argocd-operator.operators=" --timeout="$timeout_sec"
kubectl get -n "$OPERATOR_NAMESPACE" installplans

echo "Wait for ArgoCD Operator to be ready"
kubectl rollout status deployment/argocd-operator-controller-manager --timeout="$timeout_sec" -n "$OPERATOR_NAMESPACE"

echo "Create ArgoCD namespace"
cat > /tmp/argocd-namespace.yaml <<ARGOCD_NAMESPACE
apiVersion: v1
kind: Namespace
metadata:
  name: argocd
ARGOCD_NAMESPACE
kubectl apply -f /tmp/argocd-namespace.yaml


echo "Install ArgoCD"
cat > /tmp/argocd.yaml <<ARGOCD
apiVersion: argoproj.io/v1beta1
kind: ArgoCD
metadata:
  name: argocd
  namespace: argocd
spec:
  version: $ARGO_VERSION
ARGOCD
kubectl apply -f /tmp/argocd.yaml

echo "Install ArgoCD CLI $ARGO_VERSION"
curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$ARGO_VERSION/argocd-linux-amd64
sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
rm /tmp/argocd-linux-amd64

wait_for_exist argocd statefulset.apps "$timeout"
for obj in statefulset.apps/argocd-application-controller deployment.apps/argocd-redis deployment.apps/argocd-repo-server deployment.apps/argocd-server; do
  echo "Wait for $obj to be ready"
  kubectl rollout status $obj --timeout="$timeout_sec" -n argocd
done

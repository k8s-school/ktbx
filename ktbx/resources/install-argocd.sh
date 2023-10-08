#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

echo "Install ArgoCD Operator"

kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
kubectl wait installplans -n operators --for=condition=Installed -l "operators.coreos.com/argocd-operator.operators=" --timeout=120s

echo "Wait for ArgoCD Operator to be ready"
kubectl rollout status deployment/argocd-operator-controller-manager --timeout=120s -n operators

echo "Install ArgoCD"
cat >> /tmp/argocd.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd
spec: {}
EOF
kubectl apply -f /tmp/argocd.yaml

VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
echo "Install ArgoCD CLI $VERSION"
curl -sSL -o /tmp/argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
sudo install -m 555 /tmp/argocd-linux-amd64 /usr/local/bin/argocd
rm /tmp/argocd-linux-amd64
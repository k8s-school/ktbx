#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

ARGO_WORKFLOWS_VERSION="v3.5.2"

NS="argo"

echo "Create namespace $NS"
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Install Argo Workflows $ARGO_WORKFLOWS_VERSION"
kubectl apply -n "$NS" -f "https://github.com/argoproj/argo-workflows/releases/download/$ARGO_WORKFLOWS_VERSION/install.yaml"
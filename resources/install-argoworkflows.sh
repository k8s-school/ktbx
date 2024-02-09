#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

ARGO_WORKFLOWS_VERSION="v3.5.2"
ARGO_CLIENT_VERSION="v3.5.2"

NS="argo"

echo "Create namespace $NS"
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Install Argo Workflows $ARGO_WORKFLOWS_VERSION"
kubectl apply -n "$NS" -f "https://github.com/argoproj/argo-workflows/releases/download/$ARGO_WORKFLOWS_VERSION/install.yaml"

readonly argo_bin="/usr/local/bin/argo"

echo "Install Argo client $ARGO_CLIENT_VERSION"

# If argo client exists, compare current version to desired one: kind version | awk '{print $2}'
if [ -e "$argo_bin" ]; then
    current_argo_version="$(argo version --short |  awk '{print $2}')"
    if [ "$current_argo_version" == "$ARGO_CLIENT_VERSION" ]; then
        warning "argo client "$ARGO_CLIENT_VERSION" is already installed"
        exit 0
    fi
fi

curl --create-dirs --output-dir /tmp/ -sLO https://github.com/argoproj/argo-workflows/releases/download/$ARGO_CLIENT_VERSION/argo-linux-amd64.gz
gunzip /tmp/argo-linux-amd64.gz
chmod +x /tmp/argo-linux-amd64

sudo install -m 555 /tmp/argo-linux-amd64 /usr/local/bin/argo
rm /tmp/argo-linux-amd64
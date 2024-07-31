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

readonly argo_bin="/usr/local/bin/argo"

echo "Install Argo client $ARGO_WORKFLOWS_VERSION"

# If argo client exists, compare current version to desired one: kind version | awk '{print $2}'
if [ -e "$argo_bin" ]; then
    current_version="$(argo version --short |  awk '{print $2}')"
else
    current_version=""
fi

if [ "$current_version" == "$ARGO_WORKFLOWS_VERSION" ]; then
    echo "WARN: argo client $ARGO_WORKFLOWS_VERSION is already installed"
else
    tmp_dir=$(mktemp -d --suffix "-ktbx-argowf")
    echo "Install Argo-workflow CLI $ARGO_WORKFLOWS_VERSION"
    curl -sSL -o "$tmp_dir"/argo-linux-amd64.gz https://github.com/argoproj/argo-workflows/releases/download/$ARGO_WORKFLOWS_VERSION/argo-linux-amd64.gz
    gunzip "$tmp_dir"/argo-linux-amd64.gz
    sudo install -m 555 "$tmp_dir"/argo-linux-amd64 /usr/local/bin/argo
fi


rm -r "$tmp_dir"

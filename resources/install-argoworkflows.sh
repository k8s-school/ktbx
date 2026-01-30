#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

ARGO_WORKFLOWS_VERSION="v3.5.2"
KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin/}"

NS="argo"

if [ -w "$KTBX_INSTALL_DIR" ]; then
    SUDO_CMD=""
else
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
      SUDO_CMD="sudo"
    else
      echo "ERROR: No write access to $KTBX_INSTALL_DIR and sudo is unavailable or restricted."
      exit 1
    fi
fi

echo "Create namespace $NS"
kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

echo "Install Argo Workflows $ARGO_WORKFLOWS_VERSION"
kubectl apply -n "$NS" -f "https://github.com/argoproj/argo-workflows/releases/download/$ARGO_WORKFLOWS_VERSION/install.yaml"

readonly argo_bin="$KTBX_INSTALL_DIR/argo"

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
    $SUDO_CMD install -m 555 "$tmp_dir"/argo-linux-amd64 "$argo_bin"
fi


rm -r "$tmp_dir"

#!/bin/bash

# Install kubectl
# @author Fabrice Jammes

set -euo pipefail

# Configuration

KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin}"

KUBECTL_VERSION="v1.30.0"
KUBECTL_BIN="$KTBX_INSTALL_DIR/kubectl"

# Detect Operating System and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="arm"   ;;
esac

# Handle privilege escalation if directory is not writable
SUDO_CMD=""
if [[ ! -w "$KTBX_INSTALL_DIR" ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    else
        echo "ERROR: No write access to $KTBX_INSTALL_DIR and sudo is missing." >&2
        exit 1
    fi
fi

# Check if the desired version is already installed
if [[ -x "$KUBECTL_BIN" ]]; then
    CURRENT_VERSION=$(kubectl version --client | grep "^Client Version" | awk '{print $3}')
    if [[ "$CURRENT_VERSION" == "$KUBECTL_VERSION" ]]; then
        echo "INFO: kubectl $KUBECTL_VERSION is already installed"
        exit 0
    fi
fi

# Create temporary directory and ensure cleanup on exit
TMP_DIR=$(mktemp -d -t kubectl-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and install the binary
echo "Downloading kubectl $KUBECTL_VERSION for $OS/$ARCH..."
curl -Lo "$TMP_DIR/kubectl" "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/$OS/$ARCH/kubectl"
curl -Lo "$TMP_DIR/kubectl.sha256" "https://dl.k8s.io/$KUBECTL_VERSION/bin/$OS/$ARCH/kubectl.sha256"
echo "$(cat "$TMP_DIR/kubectl.sha256")  $TMP_DIR/kubectl" | sha256sum --check

$SUDO_CMD install -m 0755 "$TMP_DIR/kubectl" "$KUBECTL_BIN"

echo "Successfully installed kubectl $KUBECTL_VERSION in $KTBX_INSTALL_DIR"

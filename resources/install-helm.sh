#!/bin/bash

# Install Helm on the client machine
# @author Fabrice Jammes

set -euo pipefail

# Configuration
KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin}"
HELM_BIN="$KTBX_INSTALL_DIR/helm"
HELM_VERSION="3.16.2"

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
if [[ -x "$HELM_BIN" ]]; then
    CURRENT_VERSION=$(helm version --short | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+')
    if [[ "$CURRENT_VERSION" == "v$HELM_VERSION" ]]; then
        echo "INFO: helm v$HELM_VERSION is already installed"
        exit 0
    fi
fi

# Create temporary directory and ensure cleanup on exit
TMP_DIR=$(mktemp -d -t helm-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and install the binary
echo "Downloading helm v$HELM_VERSION for $OS/$ARCH..."
curl -o "$TMP_DIR/helm.tgz" "https://get.helm.sh/helm-v$HELM_VERSION-$OS-$ARCH.tar.gz"
tar -C "$TMP_DIR" -zxf "$TMP_DIR/helm.tgz"

$SUDO_CMD install -m 0755 "$TMP_DIR/$OS-$ARCH/helm" "$HELM_BIN"

echo "Successfully installed helm v$HELM_VERSION in $KTBX_INSTALL_DIR"

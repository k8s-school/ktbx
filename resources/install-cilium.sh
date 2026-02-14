#!/bin/bash

# Install Cilium cli and CNI plugin

# @author Fabrice Jammes

set -euo pipefail

# Configuration
KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin}"
CILIUM_CLI_VERSION="v0.18.6"
CILIUM_VERSION="1.18.0"
CILIUM_BIN="$KTBX_INSTALL_DIR/cilium"

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
if [[ -x "$CILIUM_BIN" ]]; then
    CURRENT_VERSION=$("$CILIUM_BIN" version --client 2>/dev/null | grep "cilium-cli" | awk '{print $2}' || echo "unknown")
    if [[ "$CURRENT_VERSION" == "$CILIUM_CLI_VERSION" ]]; then
        echo "INFO: cilium CLI $CILIUM_CLI_VERSION is already installed"
        exit 0
    fi
fi

# Create temporary directory and ensure cleanup on exit
TMP_DIR=$(mktemp -d -t cilium-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and install the Cilium CLI
echo "Downloading cilium CLI $CILIUM_CLI_VERSION for $OS/$ARCH..."
curl -L --fail "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-$OS-$ARCH.tar.gz" -o "$TMP_DIR/cilium.tar.gz"
curl -L --fail "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/cilium-$OS-$ARCH.tar.gz.sha256sum" -o "$TMP_DIR/cilium.tar.gz.sha256sum"
cd "$TMP_DIR" && sha256sum --check cilium.tar.gz.sha256sum
tar -xzf "$TMP_DIR/cilium.tar.gz" -C "$TMP_DIR"

$SUDO_CMD install -m 0755 "$TMP_DIR/cilium" "$CILIUM_BIN"

echo "Successfully installed cilium CLI $CILIUM_CLI_VERSION in $KTBX_INSTALL_DIR"

# Install cilium
cilium install --version ${CILIUM_VERSION}

echo "Wait for cilium daemonset to be ready"
kubectl rollout status -n kube-system --timeout=600s daemonset/cilium
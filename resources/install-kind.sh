#!/bin/bash

# Install Kind on the client machine
# @author Fabrice Jammes

set -euo pipefail

# Configuration
KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin}"
KIND_BIN="$KTBX_INSTALL_DIR/kind"
KIND_VERSION="{{ .KindVersion }}"

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
if [[ -x "$KIND_BIN" ]]; then
    CURRENT_VERSION="v$("$KIND_BIN" version -q)"
    if [[ "$CURRENT_VERSION" == "$KIND_VERSION" ]]; then
        echo "INFO: kind $KIND_VERSION is already installed"
        exit 0
    fi
fi

# Detect Operating System and Architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    armv7l)  ARCH="arm"   ;;
esac

# Create temporary directory and ensure cleanup on exit
TMP_DIR=$(mktemp -d -t kind-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and install the binary
echo "Downloading kind $KIND_VERSION for $OS/$ARCH..."
curl -Lo "$TMP_DIR/kind" "https://github.com/kubernetes-sigs/kind/releases/download/$KIND_VERSION/kind-$OS-$ARCH"

$SUDO_CMD install -m 0755 "$TMP_DIR/kind" "$KIND_BIN"

echo "Successfully installed kind $KIND_VERSION in $KTBX_INSTALL_DIR"

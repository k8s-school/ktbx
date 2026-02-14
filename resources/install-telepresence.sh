#!/bin/bash

# Install Telepresence on the client machine
# @author Fabrice Jammes

set -euo pipefail

# Configuration
KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin}"
TELEPRESENCE_BIN="$KTBX_INSTALL_DIR/telepresence"
TELEPRESENCE_VERSION="v2.15.0"

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
if [[ -x "$TELEPRESENCE_BIN" ]]; then
    CURRENT_VERSION=$("$TELEPRESENCE_BIN" version 2>/dev/null | grep "Client" | awk '{print $2}' || echo "unknown")
    if [[ "$CURRENT_VERSION" == "$TELEPRESENCE_VERSION" ]]; then
        echo "INFO: telepresence $TELEPRESENCE_VERSION is already installed"
        exit 0
    fi
fi

# Create temporary directory and ensure cleanup on exit
TMP_DIR=$(mktemp -d -t telepresence-install.XXXXXX)
trap 'rm -rf "$TMP_DIR"' EXIT

# Download and install the binary
echo "Downloading telepresence $TELEPRESENCE_VERSION for $OS/$ARCH..."
curl -fL "https://app.getambassador.io/download/tel2oss/releases/download/$TELEPRESENCE_VERSION/telepresence-$OS-$ARCH" -o "$TMP_DIR/telepresence"

$SUDO_CMD install -m 0755 "$TMP_DIR/telepresence" "$TELEPRESENCE_BIN"

echo "Successfully installed telepresence $TELEPRESENCE_VERSION in $KTBX_INSTALL_DIR"
#!/bin/bash

# Install Cilium cli and CNI plugin

# @author Fabrice Jammes

set -euo pipefail

# Configuration
KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin}"
CILIUM_CLI_VERSION="v0.18.6"
CILIUM_VERSION="1.18.15"
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

# Install the Cilium CLI only if the desired version is not already present.
# NOTE: this only caches the CLI binary download; the CNI installation below
# must always run, otherwise a freshly created cluster is left without a CNI.
CURRENT_VERSION=""
if [[ -x "$CILIUM_BIN" ]]; then
    CURRENT_VERSION=$("$CILIUM_BIN" version --client 2>/dev/null | grep "cilium-cli" | awk '{print $2}' || echo "unknown")
fi

if [[ "$CURRENT_VERSION" == "$CILIUM_CLI_VERSION" ]]; then
    echo "INFO: cilium CLI $CILIUM_CLI_VERSION is already installed"
else
    # Create temporary directory and ensure cleanup on exit
    TMP_DIR=$(mktemp -d -t cilium-install.XXXXXX)
    trap 'rm -rf "$TMP_DIR"' EXIT

    # Download and install the Cilium CLI
    echo "Downloading cilium CLI $CILIUM_CLI_VERSION for $OS/$ARCH..."
    # Keep the upstream file name: the .sha256sum file refers to it
    TARBALL="cilium-$OS-$ARCH.tar.gz"
    curl -L --fail "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/$TARBALL" -o "$TMP_DIR/$TARBALL"
    curl -L --fail "https://github.com/cilium/cilium-cli/releases/download/$CILIUM_CLI_VERSION/$TARBALL.sha256sum" -o "$TMP_DIR/$TARBALL.sha256sum"
    (cd "$TMP_DIR" && sha256sum --check "$TARBALL.sha256sum")
    tar -xzf "$TMP_DIR/$TARBALL" -C "$TMP_DIR"

    $SUDO_CMD install -m 0755 "$TMP_DIR/cilium" "$CILIUM_BIN"

    echo "Successfully installed cilium CLI $CILIUM_CLI_VERSION in $KTBX_INSTALL_DIR"
fi

# Install cilium CNI into the cluster (always run, even when the CLI was cached)
cilium install --version ${CILIUM_VERSION}

echo "Wait for cilium daemonset to be ready"
kubectl rollout status -n kube-system --timeout=600s daemonset/cilium
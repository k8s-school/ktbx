#!/bin/bash

# Install kubectl
# @author Fabrice Jammes

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin/}"

KUBECTL_VERSION="v1.30.0"
KUBECTL_BIN="$KTBX_INSTALL_DIR/kubectl"

OS="$(uname -s)"
test "$OS" = "Linux" && OS="linux"

ARCH="$(uname -m)"
test "$ARCH" = "aarch64" && ARCH="arm64"
test "$ARCH" = "x86_64" && ARCH="amd64"

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

# If kind exists, compare current version to desired one
 if [ -e $KUBECTL_BIN ]; then
    CURRENT_KUBECTL_VERSION=$(kubectl version --client | grep "^Client Version" | awk '{print $3}')
    if [ "$CURRENT_KUBECTL_VERSION" != "$KUBECTL_VERSION" ]; then
      $SUDO_CMD rm "$KUBECTL_BIN"
    fi
fi

# Download kubectl, which is a requirement for using kind.
# TODO If kubectl exists, compare current version to desired one: kubectl version --client --short  | awk '{print $3}'
if [ ! -e $KUBECTL_BIN ]; then
    curl -Lo /tmp/kubectl https://dl.k8s.io/release/"$KUBECTL_VERSION"/bin/$OS/$ARCH/kubectl
    curl -Lo /tmp/kubectl.sha256 "https://dl.k8s.io/"$KUBECTL_VERSION"/bin/$OS/$ARCH/kubectl.sha256"
    echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check
    chmod +x /tmp/kubectl
    $SUDO_CMD mv /tmp/kubectl "$KUBECTL_BIN"
fi

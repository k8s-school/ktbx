#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash


set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

KIND_BIN="/usr/local/bin/kind"
KIND_VERSION="v0.15.0"

# If kind exists, compare current version to desired one
 if [ -e $KIND_BIN ]; then
    CURRENT_KIND_VERSION="v$(kind version -q)"
    if [ "$CURRENT_KIND_VERSION" != "$KIND_VERSION" ]; then
      sudo rm "$KIND_BIN"
    fi
fi

OS="$(uname -s)"
test "$OS" = "Linux" && OS="linux"

ARCH="$(uname -m)"
test "$ARCH" = "aarch64" && ARCH="arm64"
test "$ARCH" = "x86_64" && ARCH="amd64"


if [ ! -e $KIND_BIN ]; then
    curl -Lo /tmp/kind https://github.com/kubernetes-sigs/kind/releases/download/"$KIND_VERSION"/kind-$OS-$ARCH
    chmod +x /tmp/kind
    sudo mv /tmp/kind "$KIND_BIN"
fi
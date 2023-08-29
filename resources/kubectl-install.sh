#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash


set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

KUBECTL_VERSION="1.25.0"
KUBECTL_BIN="/usr/local/bin/kubectl"

# Download kubectl, which is a requirement for using kind.
# TODO If kubectl exists, compare current version to desired one: kubectl version --client --short  | awk '{print $3}'
if [ ! -e $KUBECTL_BIN ]; then
    curl -Lo /tmp/kubectl https://dl.k8s.io/release/"$KUBECTL_VERSION"/bin/$OS/$ARCH/kubectl
    curl -Lo /tmp/kubectl.sha256 "https://dl.k8s.io/"$KUBECTL_VERSION"/bin/$OS/$ARCH/kubectl.sha256"
    echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check
    chmod +x /tmp/kubectl
    sudo mv /tmp/kubectl "$KUBECTL_BIN"
fi
#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

usage() {
    cat << EOD

Usage: `basename $0` [options]

  Available options:
    -h           This message

  Install kind, kubectl and k8s-toolbox which then manages a Kubernetes cluster with kind
EOD
}

# get the options
while getopts h c ; do
    case $c in
        h) usage ; exit 1 ;;
    esac
done
shift $(($OPTIND - 1))

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi


KUBECTL_BIN="/usr/local/bin/kubectl"
KUBECTL_VERSION="v1.25.0"
KIND_BIN="/usr/local/bin/kind"
KIND_VERSION="v0.15.0"
K8S_TOOLBOX_BIN="/usr/local/bin/k8s-toolbox"
K8S_TOOLBOX_VERSION='v1.0.2-rc1'

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

# Download kubectl, which is a requirement for using kind.
# TODO If kubectl exists, compare current version to desired one: kubectl version --client --short  | awk '{print $3}'
if [ ! -e $KUBECTL_BIN ]; then
    curl -Lo /tmp/kubectl https://dl.k8s.io/release/"$KUBECTL_VERSION"/bin/$OS/$ARCH/kubectl
    curl -Lo /tmp/kubectl.sha256 "https://dl.k8s.io/"$KUBECTL_VERSION"/bin/$OS/$ARCH/kubectl.sha256"
    echo "$(cat /tmp/kubectl.sha256)  /tmp/kubectl" | sha256sum --check
    chmod +x /tmp/kubectl
    sudo mv /tmp/kubectl "$KUBECTL_BIN"
fi

# If k8s-toolbox exists, compare current version to desired one
# TODO try to run k8s-toolbox instead, it can be in an other place than K8S_TOOLBOX_BIN
# TODO use `which` to perform above tasks?
if [ -e $K8S_TOOLBOX_BIN ]; then
    CURRENT_K8S_TOOLBOX_VERSION="$(k8s-toolbox version -q | tail -n 1)"
    if [ "$CURRENT_K8S_TOOLBOX_VERSION" != "$K8S_TOOLBOX_VERSION" ]; then
      sudo rm "$K8S_TOOLBOX_BIN"
    fi
fi

if [ ! -e $K8S_TOOLBOX_BIN ]; then

    VERSION=""
    RELEASES_URL="https://github.com/k8s-school/k8s-toolbox/releases"
    FILE_BASENAME="k8s-toolbox"
    LATEST="$(curl -s https://api.github.com/repos/k8s-school/k8s-toolbox/releases/latest | jq --raw-output '.tag_name')"

    test -z "$K8S_TOOLBOX_VERSION" && K8S_TOOLBOX_VERSION="$LATEST"

    test -z "$K8S_TOOLBOX_VERSION" && {
        echo "Unable to get k8s-toolbox version." >&2
        exit 1
    }

    BIN_FILE="${FILE_BASENAME}_${OS}_${ARCH}"

    echo "Downloading k8s-toolbox $K8S_TOOLBOX_VERSION..."
    curl -Lo "/tmp/$BIN_FILE" "$RELEASES_URL/download/$K8S_TOOLBOX_VERSION/$BIN_FILE"
    curl -Lo /tmp/k8s-toolbox.checksums.txt "$RELEASES_URL/download/$K8S_TOOLBOX_VERSION/checksums.txt"
    echo "Verifying checksums..."
    (cd /tmp && sha256sum --ignore-missing --check k8s-toolbox.checksums.txt)
    chmod +x "/tmp/$BIN_FILE"
    sudo mv "/tmp/$BIN_FILE" "$K8S_TOOLBOX_BIN"
fi

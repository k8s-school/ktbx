#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

usage() {
    cat << EOD

Usage: `basename $0` [options]

  Available options:
    -h           This message

  Install kind, kubectl and kind-helper which then manages a Kubernetes cluster with kind
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
KINDHELPER_BIN="/usr/local/bin/kind-helper"
KINDHELPER_VERSION='v1.0.2-rc1'

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

# If kind-helper exists, compare current version to desired one
# TODO try to run kind-helper instead, it can be in an other place than KINDHELPER_BIN
# TODO use `which` to perform above tasks?
if [ -e $KINDHELPER_BIN ]; then
    CURRENT_KINDHELPER_VERSION="$(kind-helper version -q | tail -n 1)"
    if [ "$CURRENT_KINDHELPER_VERSION" != "$KINDHELPER_VERSION" ]; then
      sudo rm "$KINDHELPER_BIN"
    fi
fi

if [ ! -e $KINDHELPER_BIN ]; then

    VERSION=""
    RELEASES_URL="https://github.com/k8s-school/kind-helper/releases"
    FILE_BASENAME="kind-helper"
    LATEST="$(curl -s https://api.github.com/repos/k8s-school/kind-helper/releases/latest | jq --raw-output '.tag_name')"

    test -z "$KINDHELPER_VERSION" && KINDHELPER_VERSION="$LATEST"

    test -z "$KINDHELPER_VERSION" && {
        echo "Unable to get kind-helper version." >&2
        exit 1
    }

    BIN_FILE="${FILE_BASENAME}_${OS}_${ARCH}"

    echo "Downloading kind-helper $KINDHELPER_VERSION..."
    curl -Lo "/tmp/$BIN_FILE" "$RELEASES_URL/download/$KINDHELPER_VERSION/$BIN_FILE"
    curl -Lo /tmp/kind-helper.checksums.txt "$RELEASES_URL/download/$KINDHELPER_VERSION/checksums.txt"
    echo "Verifying checksums..."
    (cd /tmp && sha256sum --ignore-missing --check kind-helper.checksums.txt)
    chmod +x "/tmp/$BIN_FILE"
    sudo mv "/tmp/$BIN_FILE" "$KINDHELPER_BIN"
fi

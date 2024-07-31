#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash


set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

KIND_BIN="/usr/local/bin/kind"
KIND_VERSION="{{ .KindVersion }}"

# If kind exists, compare current version to desired one
if [ -e $KIND_BIN ]; then
  current_version="v$(kind version -q)"
else
  current_version=""
fi

if [ "$current_version" == "$KIND_VERSION" ]; then
  echo "WARN: kind $KIND_VERSION is already installed"
else
  OS="$(uname -s)"
  test "$OS" = "Linux" && OS="linux"

  ARCH="$(uname -m)"
  test "$ARCH" = "aarch64" && ARCH="arm64"
  test "$ARCH" = "x86_64" && ARCH="amd64"

  tmp_dir=$(mktemp -d --suffix "-ktbx-kind")
  curl -Lo "$tmp_dir/kind" https://github.com/kubernetes-sigs/kind/releases/download/"$KIND_VERSION"/kind-$OS-$ARCH
  sudo install -m 555 "$tmp_dir/kind" "$KIND_BIN"
fi

rm -r "$tmp_dir"

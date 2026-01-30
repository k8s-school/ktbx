#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash


set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin/}"

KIND_BIN="$KTBX_INSTALL_DIR/kind"
KIND_VERSION="{{ .KindVersion }}"

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
  $SUDO_CMD install -m 555 "$tmp_dir/kind" "$KIND_BIN"
  rm -r "$tmp_dir"
fi


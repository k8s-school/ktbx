#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash

set -euxo pipefail

KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin/}"

helm_bin="$KTBX_INSTALL_DIR/helm"
helm_version="3.16.2"

# If helm exists, compare current version to desired one
if [ -e $helm_bin ]; then
  current_version=$(helm version --short)
else
  current_version=""
fi

if  [[ $current_version =~ "$helm_version" ]]; then
  echo "WARN: helm $helm_version is already installed"
else
  tmp_dir=$(mktemp -d --suffix "-ktbx-helm")
  curl -o "$tmp_dir"/helm.tgz https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz
  tar -C "$tmp_dir" -zxvf "$tmp_dir"/helm.tgz
  sudo install -m 555 "$tmp_dir"/linux-amd64/helm "$helm_bin"
  rm -r "$tmp_dir"
fi

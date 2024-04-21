#!/bin/bash

# Install Cilium cli and CNI plugin

# @author Fabrice Jammes

set -euxo pipefail

# Retrieve Cilium clie version with:
# curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CILIUM_CLI_VERSION="v0.16.4"
CILIUM_VERSION="1.15.2"
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

cilium install --version "$CILIUM_VERSION"

echo "Wait for cilium daemonset to be ready"
kubectl rollout status -n kube-system --timeout=600s daemonset/cilium
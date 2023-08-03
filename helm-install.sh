#!/bin/bash

# Install helm

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

HELM_VERSION="3.3.3"
wget -O /tmp/helm.tgz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz

cd /tmp
tar zxvf /tmp/helm.tgz
rm /tmp/helm.tgz
chmod +x /tmp/linux-amd64/helm
mv /tmp/linux-amd64/helm /usr/local/bin/helm

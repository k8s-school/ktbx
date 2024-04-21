#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash

set -euxo pipefail

HELM_VERSION="3.14.4"
curl -o /tmp/helm.tgz https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz

cd /tmp
tar zxvf /tmp/helm.tgz
rm /tmp/helm.tgz
sudo install -m 555 /tmp/linux-amd64/helm /usr/local/bin/helm
rm /tmp/linux-amd64/helm

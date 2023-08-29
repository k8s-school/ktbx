#!/bin/bash

# Install Helm on the client machine

# @author Fabrice Jammes
#!/bin/bash


set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

KUBECTL_VERSION=1.25.0
wget -O /usr/local/bin/kubectl \
    https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
chmod +x /usr/local/bin/kubectl
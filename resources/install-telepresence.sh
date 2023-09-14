#!/bin/bash

# Install helm

set -euxo pipefail

VERSION="v2.15.0"
INSTALL_PATH="/usr/local/bin"

# Download the binary (~95 MB):
sudo curl -fL https://app.getambassador.io/download/tel2oss/releases/download/$VERSION/telepresence-linux-amd64 -o "$INSTALL_PATH"/telepresence

# Make the binary executable:
sudo chmod a+x "$INSTALL_PATH"/telepresence

telepresence helm upgrade
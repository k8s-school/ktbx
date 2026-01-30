#!/bin/bash

# Install helm

set -euxo pipefail

KTBX_INSTALL_DIR="${KTBX_INSTALL_DIR:-/usr/local/bin/}"

VERSION="v2.15.0"

# Download the binary (~95 MB):
sudo curl -fL https://app.getambassador.io/download/tel2oss/releases/download/$VERSION/telepresence-linux-amd64 -o "$KTBX_INSTALL_DIR"/telepresence

# Make the binary executable:
sudo chmod a+x "$KTBX_INSTALL_DIR"/telepresence

telepresence helm upgrade
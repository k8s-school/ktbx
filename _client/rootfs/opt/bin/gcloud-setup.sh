#!/bin/sh

set -euxo pipefail

cp /opt/gcp/env-gcp.example.sh $HOME/env-gcp.sh
. $HOME/env-gcp.sh
gcloud auth login
gcloud config set project $PROJECT

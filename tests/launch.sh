#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Launch application to test here
"$DIR"/run.sh

echo "Pods are up:"
kubectl get pods

# Launch application integration test here
"$DIR"/run-nginx.sh

# TODO Add strong check for startup
sleep 10


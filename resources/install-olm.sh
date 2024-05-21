#!/bin/bash

# Install operator-lifecycle-manager inside k8s

# @author Fabrice Jammes

set -euxo pipefail

olm_version="v0.28.0"
timeout_sec="600s"

echo "Install operator-lifecycle-manager $olm_version"

curl -L https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$olm_version/install.sh -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh "$olm_version"

echo "Wait for operator-lifecycle-manager to be ready"
kubectl rollout status -n olm deployment/olm-operator --timeout="$timeout_sec"

echo "Wait for operatorhubio-catalog pod to be ready"

# Sometime the first operatorhubio-catalog pod is failing
# and the 'kubectl wait' fails waiting for it, so a retry is needed
counter=0
max_retry=5
while ! kubectl wait -n olm pod --for=condition=Ready -l olm.catalogSource=operatorhubio-catalog --timeout="$timeout_sec"
do
    if [ $counter -eq $max_retry ]; then
        break
    fi
    counter=$((counter+1))
done

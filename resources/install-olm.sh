#!/bin/bash

# Install operator-lifecycle-manager inside k8s

# @author Fabrice Jammes

set -euxo pipefail

OLM_VERSION="v0.25.0"

echo "Install operator-lifecycle-manager $OLM_VERSION"

curl -L https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$OLM_VERSION/install.sh -o /tmp/install.sh
chmod +x /tmp/install.sh
/tmp/install.sh "$OLM_VERSION"

echo "Wait for operator-lifecycle-manager to be ready"
kubectl rollout status deployment/olm-operator --timeout=120s -n olm

echo "Wait for operatorhubio-catalog pod to be ready"

# Sometime the first operatorhubio-catalog pod is failing
# and the 'kubectl wait' fails waiting for it
counter=0
while [ $counter -le 1 ]
do
    kubectl wait -n olm pod --for=condition=Ready -l olm.catalogSource=operatorhubio-catalog --timeout=120s
    if [ $? -eq 0 ]; then
        break
    fi
    counter=$((counter+1))
done
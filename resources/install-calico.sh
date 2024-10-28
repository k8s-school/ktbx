#!/bin/bash

# Install Cilium cli and CNI plugin

# @author Fabrice Jammes

set -euxo pipefail

# Install calico cni plugin
CALICO_VERSION="v3.28.2"

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/$CALICO_VERSION/manifests/custom-resources.yaml


echo "Wait for calico pods to be ready"
kubectl wait --for=condition=Ready pods --all -n calico-system --timeout=600s
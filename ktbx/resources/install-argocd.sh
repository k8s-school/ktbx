#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

echo "Install ArgoCD Operator"

kubectl create -f https://operatorhub.io/install/argocd-operator.yaml
kubectl wait installplans -n operators --for=condition=Installed -l "operators.coreos.com/argocd-operator.operators=" --timeout=120s

echo "Wait for ArgoCD Operator to be ready"
kubectl rollout status deployment/argocd-operator-controller-manager --timeout=120s -n operators

echo "Install ArgoCD"
cat >> /tmp/argocd.yaml <<EOF
apiVersion: argoproj.io/v1alpha1
kind: ArgoCD
metadata:
  name: argocd
spec: {}
EOF
kubectl apply -f /tmp/argocd.yaml
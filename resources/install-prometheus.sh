#!/bin/bash

# Install ArgoCD Operator inside k8s

# @author Fabrice Jammes

set -euxo pipefail

PROMETHEUS_CHART_VERSION="69.3.0"

NS="monitoring"

TMP_DIR=$(mktemp -d --suffix "-ktbx-prometheus")

cat > "$TMP_DIR"/values.yaml <<EOF
prometheus:
  prometheusSpec:
    ## Prometheus StorageSpec for persistent data
    ## ref: https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/storage.md
    ##
    storageSpec:
    ## Using PersistentVolumeClaim
    ##
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
EOF

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
helm repo update
helm install --version "$PROMETHEUS_CHART_VERSION" prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring  -f "$TMP_DIR"/values.yaml --create-namespace

#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)


START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

ERROR!!:

CIUX_VERSION="v0.0.7-rc2"
go install github.com/k8s-school/ciux@"$CIUX_VERSION"

# Test report file (YAML format for better GHA integration)
# Check that HOME_CI_RESULT_FILE is set
HOME_CI_RESULT_FILE="${HOME_CI_RESULT_FILE:-}"
if [ -z "$HOME_CI_RESULT_FILE" ]; then
    TEST_REPORT="$DIR/../e2e-report.yaml"
    echo "WARNING: HOME_CI_RESULT_FILE is not set, using temporary file $TEST_REPORT"
else
    TEST_REPORT="$HOME_CI_RESULT_FILE"
fi

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$TEST_REPORT")"

# Function to log test step (store in variable for later)
log_step() {
    local phase="$1"
    local status="$2"
    local message="$3"
    local timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    step="  - phase: $phase
    status: $status
    message: \"$message\"
    timestamp: $timestamp
"
    echo "[$timestamp] $phase: $status - $message"
    cat >> "$TEST_REPORT" <<EOF
$step
EOF
}

# Initialize YAML report
cat > "$TEST_REPORT" <<EOF
# KTBX E2E Test Report
test_run:
  start_time: $START_TIME
  runner: $(hostname)

environment:
  os: $(uname -s)
  arch: $(uname -m)
  shell: $0

steps:
EOF

echo "=== KTBX E2E Test Suite ==="
echo "Start time: $START_TIME"
echo "Test report: $TEST_REPORT"
echo "=========================="

# Phase 1: Build ktbx
echo "Phase 1: Building ktbx..."
if go install $DIR/..; then
    log_step "build" "passed" "ktbx binary installed successfully"
    echo "✅ ktbx build successful"
else
    log_step "build" "failed" "Failed to install ktbx binary"
    echo "❌ ktbx build failed"
    exit 1
fi


# Phase 2: Install Kind
echo "Phase 2: Installing Kind..."
if ktbx install kind; then
    log_step "kind_install" "passed" "Kind installed successfully"
    echo "✅ Kind installation successful"
else
    log_step "kind_install" "failed" "Failed to install Kind"
    echo "❌ Kind installation failed"
    exit 1
fi

if ktbx install kubectl; then
    log_step "kubectl_install" "passed" "Kubectl installed successfully"
    echo "✅ Kubectl installation successful"
else
    log_step "kubectl_install" "failed" "Failed to install Kubectl"
    echo "❌ Kubectl installation failed"
    exit 1
fi

# Phase 3: Create cluster
CLUSTER_NAME=$(ciux get clustername "$DIR/..")
echo "Phase 3: Creating Kind cluster..."
if ktbx create --single -n "$CLUSTER_NAME"; then
    log_step "cluster_create" "passed" "Kind cluster '$CLUSTER_NAME' created successfully"
    echo "✅ Cluster creation successful"
else
    log_step "cluster_create" "failed" "Failed to create Kind cluster"
    echo "❌ Cluster creation failed"
    exit 1
fi

# Phase 4: Verify cluster - pods
echo "Phase 4: Verifying cluster (checking system pods)..."
if kubectl get pods -n kube-system > /dev/null 2>&1; then
    POD_COUNT=$(kubectl get pods -n kube-system --no-headers 2>/dev/null | wc -l)
    log_step "verify_pods" "passed" "Found $POD_COUNT system pods running"
    echo "✅ System pods verification successful ($POD_COUNT pods)"
else
    log_step "verify_pods" "failed" "System pods verification failed"
    echo "❌ System pods verification failed"
    exit 1
fi

# Phase 5: Verify cluster - nodes
echo "Phase 5: Verifying cluster (checking nodes)..."
if kubectl get nodes > /dev/null 2>&1; then
    NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    log_step "verify_nodes" "passed" "Found $NODE_COUNT nodes in cluster"
    echo "✅ Node verification successful ($NODE_COUNT nodes)"
else
    log_step "verify_nodes" "failed" "Node verification failed"
    echo "❌ Node verification failed"
    exit 1
fi

# Final summary - write all steps and remaining sections
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TOTAL_DURATION=$(( $(date -d "$END_TIME" +%s) - $(date -d "$START_TIME" +%s) ))

# Append all steps to the YAML file
cat >> "$TEST_REPORT" <<EOF
summary:
  end_time: $END_TIME
  duration_seconds: $TOTAL_DURATION
  total_steps: 5
  passed_steps: 5
  failed_steps: 0
  overall_status: passed
  success_rate: 100%
EOF

echo "=========================="
echo "🎉 ALL TESTS PASSED!"
echo "Duration: ${TOTAL_DURATION}s"
echo "Test report: $TEST_REPORT"
echo "=========================="

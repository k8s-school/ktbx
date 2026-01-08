#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

# Test report file (YAML format for better GHA integration)
# home-ci will set HOME_CI_LOG_DIR and HOME_CI_WORKSPACE_ID
LOG_DIR="${HOME_CI_LOG_DIR:-$(mktemp -d --suffix -ktbx)}"
WORKSPACE_ID="${HOME_CI_WORKSPACE_ID:-$(date +%Y%m%d-%H%M%S)}"
REPO_NAME="${HOME_CI_REPO_NAME:-ktbx}"
TEST_REPORT="$LOG_DIR/$REPO_NAME/$WORKSPACE_ID-e2e-report.yaml"
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$TEST_REPORT")"

# Function to log test step (store in variable for later)
STEPS=""
log_step() {
    local phase="$1"
    local status="$2"
    local message="$3"
    local timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

    STEPS+="  - phase: $phase
    status: $status
    message: \"$message\"
    timestamp: $timestamp
"

    echo "[$timestamp] $phase: $status - $message"
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
if go install .; then
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

# Phase 3: Create cluster
echo "Phase 3: Creating Kind cluster..."
if ktbx create --single -n ktbx; then
    log_step "cluster_create" "passed" "Kind cluster 'ktbx' created successfully"
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
$STEPS
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

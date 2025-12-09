#!/bin/bash

set -euxo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

go install .

ktbx install kind
ktbx create --single -n home-ci
kubectl get pods -n kube-system
kubectl get nodes
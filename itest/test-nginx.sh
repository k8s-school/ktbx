#!/bin/sh

set -e

echo "Connect to nginx application"
kubectl run --generator=run-pod/v1 -it --image=busybox shell wget http://my-nginx
# TODO try port forwad and curl

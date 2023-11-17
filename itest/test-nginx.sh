#!/bin/sh

set -e

echo "Connect to nginx application"
kubectl run -it --image=busybox shell wget http://my-nginx

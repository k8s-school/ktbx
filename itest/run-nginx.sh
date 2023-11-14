#!/bin/sh

set -e

echo "Launch nginx application"
kubectl create deployment my-nginx --image=nginx
kubectl expose deployment my-nginx --port=80
kubectl wait --for=condition=available --timeout=600s deployment/my-nginx

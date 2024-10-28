#!/bin/sh

set -euxo pipefail

echo "Launch nginx application"
kubectl create deployment my-nginx --image=nginx
kubectl expose deployment my-nginx --port=80
kubectl wait --for=condition=available --timeout=600s deployment/my-nginx

echo "Connect to nginx application"
kubectl run -it --image=nginx client --restart=Never -- curl http://my-nginx:80

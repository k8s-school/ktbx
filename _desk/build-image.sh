#!/bin/sh

# Create docker image containing kops tools and scripts

# @author  Fabrice Jammes

set -e
#set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

IMAGE_LITE="k8sschool/k8s-toolbox-lite:latest"
IMAGE="k8sschool/k8s-toolbox:latest"

echo $DIR

# CACHE_OPT="--no-cache"
docker build --target base --tag "$IMAGE_LITE" "$DIR"
docker image build --build-arg FORCE_GO_REBUILD="$(date)" --tag "$IMAGE" "$DIR"
docker push "$IMAGE_LITE"
docker push "$IMAGE"

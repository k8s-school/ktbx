#!/bin/sh

# Create docker image containing kops tools and scripts

# @author  Fabrice Jammes

set -e
#set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

. $DIR/conf.sh

# CACHE_OPT="--no-cache"
docker image build --no-cache --target base --tag "$IMAGE_LITE" "$DIR"
docker image build --build-arg FORCE_GO_REBUILD="$(date)" --tag "$IMAGE" "$DIR"

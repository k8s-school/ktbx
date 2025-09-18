#!/bin/sh

# Create docker image containing kops tools and scripts

# @author  Fabrice Jammes

set -e
#set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

. $DIR/conf.sh

# get CACHE_OPT value from command line
if [ "$1" = "--cache" ]; then
  CACHE_OPT=""
else
  CACHE_OPT="--no-cache"
fi

docker image build $CACHE_OPT --target base --tag "$IMAGE_LITE" "$DIR"
docker image build --build-arg FORCE_GO_REBUILD="$(date)" --tag "$IMAGE" "$DIR"

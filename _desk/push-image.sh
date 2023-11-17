#!/bin/sh

# Create docker image containing kops tools and scripts

# @author  Fabrice Jammes

set -e
#set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)

. $DIR/conf.sh

docker push "$IMAGE_LITE"
docker push "$IMAGE"

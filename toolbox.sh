#!/bin/bash

# Run docker container containing kubectl tools and scripts

# @author  Fabrice Jammes

set -euo pipefail
set -x

DIR=$(cd "$(dirname "$0")"; pwd -P)
CMD=""
DEV=""
HOMEFS=""
MOUNTS=""

usage() {
    cat << EOD
Usage: $(basename "$0") [options]
Available options:
  -C            Command to launch inside container
  -h            This message

Run docker container containing k8s management tools (helm,
kubectl, ...) and scripts.

EOD
}

# Get the options
while getopts hC:Hd c ; do
    case $c in
        C) CMD="${OPTARG}" ;;
        d) DEV=true ;;
        h) usage ; exit 0 ;;
        H) HOMEFS="$HOME" ;;
        \?) usage ; exit 2 ;;
    esac
done
shift "$((OPTIND-1))"

if [ $# -ne 0 ] ; then
    usage
    exit 2
fi

if [ -z "${CMD}" ]
then
    CMD="bash"
fi
if [ "$CMD" = "zsh" -o "$CMD" = "bash" -o "$CMD" = "gcloud auth login" ]
then
    BASH_OPTS="-it"
else
    BASH_OPTS="-t"
fi
#if [ "$CMD" = "zsh" ]
#then
#   CMD="LC_ALL=C.UTF-8 zsh"
#fi

# Create home directory
if [ -z "${HOMEFS}" ]
then
    HOMEFS="$DIR/homefs"
    mkdir -p "$HOMEFS"
    if [ ! -e "$HOMEFS"/.bashrc ]; then
        curl https://raw.githubusercontent.com/k8s-school/k8s-toolbox/master/homefs/.bashrc > "$HOMEFS"/.bashrc
    fi
fi

# Launch container
#
# Use host network to easily publish k8s dashboard
IMAGE=k8sschool/k8s-toolbox
if [ "$DEV" = true ]; then
    echo "Running in development mode"
    MOUNTS="$MOUNTS -v $DIR/rootfs/opt:/opt"
fi
MOUNTS="$MOUNTS --volume $HOMEFS:$HOME"
MOUNTS="$MOUNTS --volume $HOME/.kube:$HOME/.kube"
# MOUNTS="$MOUNTS --volume $HOME/.config:$HOME/.config"
MOUNTS="$MOUNTS --volume /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
MOUNTS="$MOUNTS --volume /usr/local/share/ca-certificates:/usr/local/share/ca-certificates"

docker pull "$IMAGE"
echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
echo "   Welcome in k8s toolbox container"
echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
docker run $BASH_OPTS --net=host \
    $MOUNTS --rm \
    --user=$(id -u):$(id -g $USER) \
    -w $HOME -- \
    "$IMAGE" $CMD

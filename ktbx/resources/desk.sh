# Run docker container containing kubectl tools and scripts
# @author  Fabrice Jammes

set -euo pipefail

DIR=$(cd "$(dirname "$0")"; pwd -P)

SHOWDOCKERCMD="${SHOWDOCKERCMD:-false}"
CMD="bash"
DEV=""
HOMEFS=""
MOUNTS=""

# Create home directory
if [ -z "${HOMEFS}" ]
then
    HOMEFS="$HOME/.ktbx/homefs"
    mkdir -p "$HOMEFS"
    if [ ! -e "$HOMEFS"/.bashrc ]; then
        curl https://raw.githubusercontent.com/k8s-school/k8s-toolbox/main/_desk/homefs/.bashrc > "$HOMEFS"/.bashrc
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
MOUNTS="$MOUNTS --volume /tmp:/tmp"
MOUNTS="$MOUNTS --volume /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
MOUNTS="$MOUNTS --volume /usr/local/share/ca-certificates:/usr/local/share/ca-certificates"

if [ "$SHOWDOCKERCMD" = true ]; then
    echo "docker run -it --net=host \
$MOUNTS --rm \
--user=$(id -u):$(id -g $USER) \
-w $HOME -- \
\"$IMAGE\""
else
    docker pull -q "$IMAGE"
    echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
    echo "   Welcome in k8s toolbox desk"
    echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
    docker run -it --net=host \
        $MOUNTS --rm \
        --user=$(id -u):$(id -g $USER) \
        -w $HOME -- \
        "$IMAGE" $CMD
fi

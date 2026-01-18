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
IMAGE=docker.io/k8sschool/k8s-toolbox:latest
if [ "$DEV" = true ]; then
    echo "Running in development mode"
    MOUNTS="$MOUNTS -v $DIR/rootfs/opt:/opt"
fi

MOUNTS="$MOUNTS --volume $HOMEFS:$HOME"
MOUNTS="$MOUNTS --volume $HOME/.kube:$HOME/.kube"
MOUNTS="$MOUNTS --volume /tmp:/tmp"
MOUNTS="$MOUNTS --volume /etc/group:/etc/group:ro -v /etc/passwd:/etc/passwd:ro"
MOUNTS="$MOUNTS --volume /usr/local/share/ca-certificates:/usr/local/share/ca-certificates"

# Optional binaries that are not built inside the image
for binary in oc kind cosign trivy docker; do
    bin_path=$(which $binary) || bin_path=""
    if [ -n "$bin_path" ]; then
        MOUNTS="$MOUNTS --volume $bin_path:/usr/local/bin/$binary"
    fi
done

# Mount Docker socket for Docker daemon access
DOCKER_GROUP_ADD=""
if [ -S "/var/run/docker.sock" ]; then
    MOUNTS="$MOUNTS --volume /var/run/docker.sock:/var/run/docker.sock"
    # Get docker group ID and add user to docker group in container
    docker_gid=$(stat -c '%g' /var/run/docker.sock)
    DOCKER_GROUP_ADD="--group-add $docker_gid"
fi

if [ "$SHOWDOCKERCMD" = true ]; then
    echo "docker run -it --net=host \
$MOUNTS $DOCKER_GROUP_ADD --rm \
--user=$(id -u):$(id -g $USER) \
-w $HOME -- \
\"$IMAGE\""
else
    echo "Using local image $IMAGE"
    echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
    echo "   Welcome in k8s toolbox desk"
    echo "oOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoOoO"
    docker run -it --net=host \
        $MOUNTS $DOCKER_GROUP_ADD --rm \
        --user=$(id -u):$(id -g $USER) \
        -w $HOME -- \
        "$IMAGE" $CMD
fi

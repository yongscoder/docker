#!/bin/bash

# Usage check
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <container_name> <image_name>"
    exit 1
fi

CONTAINER_NAME=$1
IMAGE_NAME=$2

# Check if container already exists
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "Container '$CONTAINER_NAME' already exists"

    # Check if it's running
    if [ "$(docker ps -q -f name=^${CONTAINER_NAME}$)" ]; then
        echo "Container is already running. Use './exec_docker.sh $CONTAINER_NAME' to attach to it."
        exit 0
    else
        echo "Starting existing container: $CONTAINER_NAME"
        docker start $CONTAINER_NAME
        docker exec -it $CONTAINER_NAME /bin/bash
        exit 0
    fi
fi

echo "Creating and starting new container: $CONTAINER_NAME using image: $IMAGE_NAME"

# Enable X11 forwarding for GUI applications
xhost +local:docker 2>/dev/null || true

docker run -itd --user root --gpus all \
    --name $CONTAINER_NAME \
    --network host \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
    -v /dev:/dev \
    $IMAGE_NAME /bin/bash -c "tail -f /dev/null"

echo "Container started in background. Connecting..."
docker exec -it $CONTAINER_NAME /bin/bash
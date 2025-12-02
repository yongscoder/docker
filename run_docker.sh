#!/bin/bash

# Usage check
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <container_name> <image_name>"
    exit 1
fi

CONTAINER_NAME=$1
IMAGE_NAME=$2

# If container exists, remove it
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    echo "Removing existing container: $CONTAINER_NAME"
    docker rm -f $CONTAINER_NAME
fi

echo "Starting container: $CONTAINER_NAME using image: $IMAGE_NAME"

docker run -it --user root --gpus all \
    --name $CONTAINER_NAME \
    $IMAGE_NAME /bin/bash
#!/bin/bash

# Script to exec into a running Docker container
# Usage: ./exec_docker.sh <container_name>

if [ $# -eq 0 ]; then
    echo "Error: No container name provided"
    echo "Usage: $0 <container_name>"
    echo ""
    echo "Available running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    exit 1
fi

CONTAINER_NAME=$1

# Check if container exists and is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Error: Container '${CONTAINER_NAME}' is not running"
    echo ""
    echo "Available running containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"
    exit 1
fi

echo "Executing into container: ${CONTAINER_NAME}"
docker exec -it ${CONTAINER_NAME} /bin/bash

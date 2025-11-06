#!/bin/bash
# Yandex.Disk status retrieval script

# Find the Yandex.Disk container (adjust the filter to match your container name)
CONTAINER_ID=$(docker ps --filter "name=yandex_disk" --format "{{.ID}}" | head -n 1)

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: Yandex.Disk container not found"
    echo "Looking for containers matching 'yandex_disk'"
    echo ""
    echo "Available containers:"
    docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
    exit 1
fi

# Execute the status command
docker exec $CONTAINER_ID yandex-disk status -dir=yandex 2>&1
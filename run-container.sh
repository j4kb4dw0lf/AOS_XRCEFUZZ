#!/bin/bash
container_name="xrce-fuzz-container"

# Check if the container exists
if [ "$(docker ps -aq -f name=$container_name)" ]; then
    echo "Container $container_name already exists. Starting it..."
    docker start -ai $container_name
else
    echo "Container $container_name does not exist. Creating and starting it..."
    docker run -it --name=$container_name micro-xrce-dds-fuzzing-environment /bin/bash
fi
#!/bin/bash

# Define the name for your Docker image
IMAGE_NAME="micro-xrce-dds-fuzzing-environment"

echo "Building Docker image: $IMAGE_NAME"

# Build the Docker image
docker build -t "$IMAGE_NAME" .

if [ $? -eq 0 ]; then
  echo "Docker image '$IMAGE_NAME' built successfully!"
  echo "Now you can run a container using run-container.sh script."
else
  echo "Error: Docker image build failed."
fi

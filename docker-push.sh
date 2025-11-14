#!/bin/bash
# Script to build and push TransDreamerV3 image to Docker Hub

set -e

# Configuration - CHANGE THIS to your Docker Hub username
DOCKER_USERNAME="${DOCKER_USERNAME:-YOUR_USERNAME}"
IMAGE_NAME="transdreamerv3"
TAG="${1:-latest}"  # Use first argument as tag, default to 'latest'

FULL_IMAGE="${DOCKER_USERNAME}/${IMAGE_NAME}:${TAG}"

echo "=================================================="
echo "Building and pushing to Docker Hub"
echo "Image: ${FULL_IMAGE}"
echo "=================================================="
echo ""

# Check if logged in to Docker Hub
if ! docker info | grep -q "Username"; then
    echo "Not logged in to Docker Hub. Please login:"
    docker login
fi

# Build the image
echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:${TAG} -f Dockerfile .

# Tag for Docker Hub
echo "Tagging image for Docker Hub..."
docker tag ${IMAGE_NAME}:${TAG} ${FULL_IMAGE}

# Push to Docker Hub
echo "Pushing to Docker Hub..."
docker push ${FULL_IMAGE}

echo ""
echo "=================================================="
echo "Successfully pushed: ${FULL_IMAGE}"
echo ""
echo "Others can now pull it with:"
echo "  docker pull ${FULL_IMAGE}"
echo ""
echo "To run it:"
echo "  docker run --gpus all ${FULL_IMAGE}"
echo "=================================================="

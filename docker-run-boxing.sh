#!/bin/bash
# Script to build and run atari_run_boxing.sh in Docker with Comet ML support

set -e

# Check if COMET_API_KEY is set
if [ -z "$COMET_API_KEY" ]; then
    echo "WARNING: COMET_API_KEY environment variable is not set."
    echo "Comet ML logging will be disabled."
    echo "To enable Comet ML, set your API key:"
    echo "  export COMET_API_KEY='your-api-key-here'"
    echo ""
    USE_COMET="False"
else
    echo "Comet ML API key detected. Logging enabled."
    USE_COMET="True"
fi

# Docker Hub image name (change YOUR_USERNAME to your Docker Hub username)
DOCKER_IMAGE="antoninakar/transdreamerv3:latest"

# Pull the image from Docker Hub (or build locally if not available)
echo "Pulling Docker image from Docker Hub..."
if ! docker pull ${DOCKER_IMAGE}; then
    echo "Image not found on Docker Hub. Building locally..."
    docker build -t transdreamerv3:latest -f Dockerfile .
    DOCKER_IMAGE="transdreamerv3:latest"
fi

# Create logdir on host if it doesn't exist
LOGDIR="${HOME}/logdir/transdreamerv3"
mkdir -p "${LOGDIR}"

echo ""
echo "====================================================="
echo "Starting Docker container..."
echo "Logs will be saved to: ${LOGDIR}"
echo "Task: Atari Boxing"
echo "Comet ML: ${USE_COMET}"
if [ "$USE_COMET" = "True" ]; then
    echo "Project: transdreamerv3-atari"
    echo "Check Comet ML dashboard for real-time metrics!"
fi
echo "====================================================="
echo ""

# Run the container with GPU support
docker run --runtime=nvidia -it --rm \
    --gpus "device=0" \
    -v "${LOGDIR}:/logdir" \
    -e CUDA_VISIBLE_DEVICES=0 \
    -e COMET_API_KEY="${COMET_API_KEY}" \
    ${DOCKER_IMAGE} \
    bash -c "python3 dreamerv3/train.py \
        --logdir /logdir/atari_boxing_$(date +%Y%m%d-%H%M%S) \
        --configs atari \
        --task atari_boxing \
        --use_comet ${USE_COMET} \
        --comet_project transdreamerv3-atari"

# Dockerfile for running TransDreamerV3 Atari experiments
FROM nvidia/cuda:11.4.2-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/San_Francisco
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    python3-pip \
    python3.10 \
    python3.10-dev \
    vim \
    libglew-dev \
    x11-xserver-utils \
    xvfb \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set python3.10 as default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1
RUN pip3 install --upgrade pip

# Environment variables for rendering and JAX
ENV MUJOCO_GL=egl
ENV XLA_PYTHON_CLIENT_MEM_FRACTION=0.8
ENV NUMBA_CACHE_DIR=/tmp

# Install JAX with CUDA 11 support
RUN pip3 install --upgrade "jax[cuda11_pip]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

# Copy requirements and install Python dependencies
COPY transdreamerv3_8/requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

# Install additional required packages
RUN pip3 install numpy cloudpickle ruamel.yaml rich

# Install Comet ML for experiment tracking
RUN pip3 install comet-ml

# Install Atari ROMs
RUN pip3 install gym[atari,accept-rom-license]==0.19.0 autorom[accept-rom-license]

# Copy the entire project
COPY . /workspace
WORKDIR /workspace/transdreamerv3_8

# Create logdir
RUN mkdir -p /logdir && chmod 777 /logdir

# Default command
CMD ["/bin/bash"]

# Dockerfile for running TransDreamerV3 Atari experiments
FROM nvidia/cuda:12.0.1-cudnn8-devel-ubuntu20.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/San_Francisco


# Install system dependencies
RUN apt-get update && apt-get install -y \
  ffmpeg git vim curl software-properties-common grep \
  libglew-dev x11-xserver-utils xvfb wget \
  && apt-get clean

ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_ROOT_USER_ACTION=ignore
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get install -y python3.11-venv && apt-get clean
RUN python3.11 -m venv /venv --upgrade-deps
ENV PATH="/venv/bin:$PATH"
RUN pip install -U pip setuptools

# Environment variables for rendering and JAX
ENV MUJOCO_GL=egl
ENV XLA_PYTHON_CLIENT_MEM_FRACTION=0.8
ENV NUMBA_CACHE_DIR=/tmp

# Install JAX with CUDA 11 support
RUN pip install --upgrade "jax[cuda11]" -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

# Copy requirements and install Python dependencies
COPY transdreamerv3_8/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Install additional required packages
RUN pip install numpy cloudpickle ruamel.yaml rich

# Install Comet ML for experiment tracking
RUN pip install comet-ml

# Install Atari ROMs
RUN pip install ale_py==0.9.0 autorom[accept-rom-license]==0.6.1

# Copy the entire project
COPY . /workspace
WORKDIR /workspace/transdreamerv3_8

# Create logdir
RUN mkdir -p /logdir && chmod 777 /logdir

# Default command
CMD ["/bin/bash"]

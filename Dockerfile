# Dockerfile for running TransDreamerV3 Atari experiments
FROM nvidia/cuda:12.0.1-cudnn8-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/San_Francisco


# Install system dependencies
RUN apt-get update && apt-get install -y \
  ffmpeg git vim curl software-properties-common grep \
  libglew-dev x11-xserver-utils xvfb wget cmake\
  && apt-get clean

ENV PYTHONUNBUFFERED=1
ENV PIP_NO_CACHE_DIR=1
ENV PIP_ROOT_USER_ACTION=ignore
RUN apt-get update && apt-get install -y python3.10 python3-pip


RUN apt-get update
RUN ln -sf /usr/bin/python3.10 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.10 /usr/bin/python


RUN python3 --version

RUN pip install " pip<24.1" "setuptools<58.0.0"


# Environment variables for rendering and JAX
ENV MUJOCO_GL=egl
ENV XLA_PYTHON_CLIENT_MEM_FRACTION=0.8
ENV NUMBA_CACHE_DIR=/tmp

# Install JAX with CUDA 11 support
RUN pip install --upgrade "jax[cuda12]" 

# Copy requirements and install Python dependencies
COPY transdreamerv3_8/requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt

# Install additional required packages
RUN pip install "numpy<2" cloudpickle ruamel.yaml rich

# Install Atari ROMs
RUN pip install ale_py==0.9.0 autorom[accept-rom-license]==0.6.1 

# Copy the entire project
COPY . /workspace
WORKDIR /workspace/transdreamerv3_8

# Create logdir
RUN mkdir -p /logdir && chmod 777 /logdir
# Default command
CMD ["/bin/bash"]

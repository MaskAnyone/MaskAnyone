# Use NVIDIA's CUDA base image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Set the working directory
WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    libatlas-base-dev \
    libprotobuf-dev \
    libleveldb-dev \
    libsnappy-dev \
    libhdf5-serial-dev \
    protobuf-compiler \
    libboost-all-dev \
    libgflags-dev \
    libgoogle-glog-dev \
    liblmdb-dev \
    python3-dev \
    python3-pip \
    python-is-python3 \
    libopencv-dev \
    python3-opencv \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --no-cache-dir numpy==1.24.4

# Clone OpenPose repository
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git

# Copy model files
COPY models/pose/body_25/pose_iter_584000.caffemodel /workspace/openpose/models/pose/body_25/pose_iter_584000.caffemodel
COPY models/face/pose_iter_116000.caffemodel /workspace/openpose/models/face/pose_iter_116000.caffemodel
COPY models/hand/pose_iter_102000.caffemodel /workspace/openpose/models/hand/pose_iter_102000.caffemodel

# Set environment variables for CUDA and cuDNN
ENV PATH /usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV CUDNN_INCLUDE_DIR /usr/local/cuda/include
ENV CUDNN_LIB_DIR /usr/local/cuda/lib64
ENV CUDNN_LIBRARY /usr/local/cuda/lib64/libcudnn.so

# -DCUDA_ARCH_BIN="89"

# Build OpenPose
RUN cd /workspace/openpose && \
    mkdir build && cd build && \
    cmake -DBUILD_PYTHON=ON -DCUDA_ARCH_BIN="75" -DGPU_MODE=CUDA -DUSE_CUDNN=OFF -DCMAKE_BUILD_TYPE=Release .. && \
    make -j`nproc`

# Set environment variables
ENV PYTHONPATH /workspace/openpose/build/python:$PYTHONPATH
ENV PATH /workspace/openpose/build/examples/openpose:$PATH

RUN pip install fastapi uvicorn[standard] python-multipart

WORKDIR /app

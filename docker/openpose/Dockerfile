# Use NVIDIA's CUDA base image
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

# Set the working directory
WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive

ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN apt-get update && apt-get install -y libgl1 ffmpeg

RUN apt-get update \
    && apt-get install -y \
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
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir \
    numpy==1.24.4 \
    fastapi \
    uvicorn[standard] \
    python-multipart \
    gunicorn \
    opencv-python \
    gdown

# Clone OpenPose repository
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git

# Copy model files
RUN gdown https://drive.google.com/uc?id=1f-kvdjHbpvkgDECVsSPxm8NMLRgdRBj7 \
    && unzip openpose_models_full.zip \
    && cp -ru openpose_models_full/models/* /workspace/openpose/models \
    && rm openpose_models_full.zip \
    && rm -rf openpose_models_full

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

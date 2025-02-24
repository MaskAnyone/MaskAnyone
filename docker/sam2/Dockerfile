FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-devel
# @todo needed to install SAM2 dependencies, can probably be solved with multi-stage build

WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive

ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    pkg-config \
    build-essential \
    libffi-dev \
    git \
    wget

RUN pip install --upgrade --no-cache-dir \
    pip \
    setuptools \
    fastapi \
    uvicorn[standard] \
    python-multipart \
    opencv-python-headless

RUN git clone https://github.com/facebookresearch/sam2.git \
    && cd sam2 \
    && SAM2_BUILD_ALLOW_ERRORS=0 pip install -e --no-cache-dir .

RUN cd sam2/checkpoints \
    && wget https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_small.pt

WORKDIR /app

#FROM ubuntu:22.04
#FROM nvidia/cuda:11.7.1-runtime-ubuntu22.04
FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-opencv \
        wget \
        ffmpeg \
        git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN pip install \
    mediapipe==0.10.14 \
    requests \
    numpy==1.24.4 \
    torch \
    ultralytics

RUN mkdir /worker_models \
    && wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/latest/pose_landmarker_heavy.task \
        -O /worker_models/pose_landmarker_heavy.task

RUN apt-get update \
    && apt-get -y install \
        mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev mesa-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /sam2 \
    && cd /sam2 \
    && git clone https://github.com/facebookresearch/segment-anything-2.git \
    && cd segment-anything-2 \
    && pip install -e .

WORKDIR /app

FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update \
    && apt-get -y install \
    python3.10 \
    python3-pip \
    python-is-python3 \
    python3-opencv \
    python3-tk \
    libgl1 \
    libglib2.0-0 \
    libpq-dev \
    gcc \
    git-all \
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip uninstall onnxruntime onnxruntime-gpu \
    && pip install onnxruntime-gpu==1.15.1 \
    requests \
    opencv-python

RUN cd / \
    && git clone https://github.com/rohansaw/roop-for-de-identifiction \
    && cd /roop-for-de-identifiction \
    && pip install -r requirements.txt

RUN mkdir /roop-faces
COPY faces/ /roop-faces/
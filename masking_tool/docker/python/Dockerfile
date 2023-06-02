FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

WORKDIR /app

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        libgl1 \
        libglib2.0-0

RUN pip install \
    fastapi \
    mediapipe \
    uvicorn[standard] \
    ultralytics

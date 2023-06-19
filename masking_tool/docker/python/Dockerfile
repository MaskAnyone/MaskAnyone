FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-opencv \
        libgl1 \
        libglib2.0-0 \
        libpq-dev \
        gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    fastapi \
    mediapipe \
    uvicorn[standard] \
    ultralytics \
    psycopg2

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
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    fastapi \
    mediapipe \
    uvicorn[standard] \
    ultralytics \
    psycopg2 \
    requests \
    torch \
    torchvision \
    torchaudio \
    huggingface_hub \
    gdown \
    ffmpeg-python \
    moviepy

WORKDIR /
RUN git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git
WORKDIR /Retrieval-based-Voice-Conversion-WebUI
RUN pip install -r requirements.txt
COPY scripts/ /scripts/
RUN python3 /scripts/download_voice_models.py

WORKDIR /app

RUN apt-get update && apt-get -y install ffmpeg

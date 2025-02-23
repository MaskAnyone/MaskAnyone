FROM ubuntu:22.04

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
    ffmpeg \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

RUN pip install \
    fastapi \
    uvicorn[standard] \
    psycopg2 \
    requests \
    python-jose[cryptography]

# When installing it with deps, it will also install all CUDA deps even if there is not GPU
RUN pip install ultralytics==8.3.78 --no-deps

# Manually install ultralytics deps
RUN pip install \
    numpy==1.24.4 \
    psutil \
    matplotlib \
    tqdm \
    pandas \
    ultralytics-thop

RUN mkdir /backend_models \
    && wget https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11m-pose.pt \
        -O /backend_models/yolo11m-pose.pt

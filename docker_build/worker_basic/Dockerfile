FROM nvidia/cuda:11.7.1-cudnn8-runtime-ubuntu22.04

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
    ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    mediapipe \
    ultralytics \
    requests \
    torch \
    torchvision \
    torchaudio \
    huggingface_hub \
    gdown \
    ffmpeg-python \
    moviepy


# RVC
RUN cd / \
    && git clone https://github.com/RVC-Project/Retrieval-based-Voice-Conversion-WebUI.git \
    && cd Retrieval-based-Voice-Conversion-WebUI \
    && git checkout 3e455ece57a627cb29252d7c6de2b86ace9aff85 \
    && pip install -r requirements.txt

# STTN
RUN cd / \
    && git clone https://github.com/researchmm/STTN.git \
    && cd STTN \
    && mkdir ./checkpoints \
    && cd ./checkpoints \
    && sed -i 's/cuda:1/cuda:0/' /STTN/test.py \
    && sed -i 's/mp4v/vp09/' /STTN/test.py

ENV WORKER_TYPE="basic_masking"

COPY ./workers /app

CMD ["python", "basic_masking_worker.py"]

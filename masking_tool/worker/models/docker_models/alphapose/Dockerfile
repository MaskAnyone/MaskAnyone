FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

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
    libyaml-dev \
    lshw \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install pyyaml==5.2 scipy numpy \ 
    && python -m pip install cython \
    && pip3 install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu113

RUN git clone https://github.com/MVIG-SJTU/AlphaPose.git
RUN cd /AlphaPose \
    && export PATH=/usr/local/cuda/bin/:$PATH \ 
    && export LD_LIBRARY_PATH=/usr/local/cuda/lib64/:$LD_LIBRARY_PATH \ 
    && python setup.py build develop

COPY scripts/ /scripts/
RUN mkdir /AlphaPose/detector/yolo/data \
    && mkdir /AlphaPose/detector/tracker/data \
    && python3 /scripts/download_models.py
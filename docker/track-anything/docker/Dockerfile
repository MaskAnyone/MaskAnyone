FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

WORKDIR /app

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        git

RUN pip install torch torchvision

RUN git clone https://github.com/gaomingqi/Track-Anything.git .

RUN pip install -r requirements.txt

RUN apt-get -y install libgl1 libglib2.0-0 libsm6 libxrender1 libxext6 nvidia-modprobe

ENV CUDA_VISIBLE_DEVICES=0

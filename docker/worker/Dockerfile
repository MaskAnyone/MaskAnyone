FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-opencv \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    mediapipe==0.10.10 \
    requests

RUN mkdir /worker_models \
    && wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_lite/float16/latest/pose_landmarker_lite.task \
        -O /worker_models/pose_landmarker_lite.task \
    && wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/pose_landmarker_full.task \
        -O /worker_models/pose_landmarker_full.task \
    && wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/latest/pose_landmarker_heavy.task \
        -O /worker_models/pose_landmarker_heavy.task

WORKDIR /app

FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-opencv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    mediapipe==0.10.10 \
    requests

WORKDIR /app

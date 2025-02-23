FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-opencv \
        wget \
        ffmpeg \
        mesa-common-dev \
        libegl1-mesa-dev \
        libgles2-mesa-dev \
        mesa-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN pip install \
    mediapipe==0.10.14 \
    requests

RUN mkdir /worker_models \
    && wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/latest/pose_landmarker_heavy.task \
        -O /worker_models/pose_landmarker_heavy.task \
    && wget https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task \
        -O /worker_models/face_landmarker.task \
    && wget https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task \
        -O /worker_models/hand_landmarker.task

####################
# Enable this if you want to test the CLI

# When installing it with deps, it will also install all CUDA deps even if there is not GPU
#RUN pip install ultralytics==8.3.78 --no-deps

# Manually install ultralytics deps
#RUN pip install \
#    psutil \
#    matplotlib \
#    pandas \
#    tqdm \
#    pyyaml \
#    ultralytics-thop

#RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

#RUN wget https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11x-pose.pt \
#        -O /worker_models/yolo11x-pose.pt

####################

WORKDIR /app

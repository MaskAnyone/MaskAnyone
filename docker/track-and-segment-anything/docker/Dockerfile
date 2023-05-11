FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu22.04

WORKDIR /app

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        git \
        wget \
        ffmpeg \
        libsm6 \
        libxext6 \
        libgl1-mesa-glx



### Segment Anything
RUN pip install torch torchvision opencv-python pycocotools matplotlib onnxruntime onnx

RUN pip install git+https://github.com/facebookresearch/segment-anything.git


### aot benchmark
#RUN apt-get install -y ninja-build gcc

RUN pip install Pillow gdown

### Segment-and-Track-Anything
RUN git clone https://github.com/z-x-yang/Segment-and-Track-Anything . \
    && bash script/install.sh \
    && mkdir ckpt \
    && bash script/download_ckpt.sh

RUN pip install jupyter

FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive

ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN apt-get update \
    && apt-get install -y \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libprotobuf-dev \
        libleveldb-dev \
        libsnappy-dev \
        libhdf5-serial-dev \
        protobuf-compiler \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        liblmdb-dev \
        python3-dev \
        python3-pip \
        python-is-python3 \
        libopencv-dev \
        python3-opencv \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install \
    numpy==1.24.4 \
    fastapi \
    uvicorn[standard] \
    python-multipart \
    gunicorn \
    gdown

RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git

RUN gdown https://drive.google.com/uc?id=19ohrLGTdsRL7jLCb35QQBwxlY2Jg3Eye \
    && unzip openpose_models.zip -d openpose_models \
    && mv openpose_models/models/* /workspace/openpose/models \
    && rm openpose_models.zip \
    && rm -rf openpose_models \
    && ls /workspace/openpose/models \
    && ls /workspace/openpose/models/pose/body_25 \
    && ls /workspace/openpose/models/face \
    && ls /workspace/openpose/models/hand

ENV PATH /usr/local/cuda/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/cuda/lib64:$LD_LIBRARY_PATH
ENV CUDNN_INCLUDE_DIR /usr/local/cuda/include
ENV CUDNN_LIB_DIR /usr/local/cuda/lib64
ENV CUDNN_LIBRARY /usr/local/cuda/lib64/libcudnn.so

# TODO should we increase the arch here to 89 or even 90?
RUN cd /workspace/openpose && \
    mkdir build && cd build && \
    cmake -DBUILD_PYTHON=ON -DCUDA_ARCH_BIN="75" -DGPU_MODE=CUDA -DUSE_CUDNN=OFF -DCMAKE_BUILD_TYPE=Release .. && \
    make -j`nproc`

# Set environment variables
ENV PYTHONPATH /workspace/openpose/build/python:$PYTHONPATH
ENV PATH /workspace/openpose/build/examples/openpose:$PATH

WORKDIR /app

COPY ./openpose /app

CMD ["gunicorn", "-k", "uvicorn_prod_worker.UvicornProdWorker", "main:app", "--bind=0.0.0.0:8000"]

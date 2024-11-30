# Build stage
FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04 AS builder

WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN apt-get update \
    && apt-get install -y \
        ffmpeg \
        git \
        python3-dev \
        python3-pip \
        python-is-python3 \
        libopencv-dev \
        python3-opencv \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install numpy==1.24.4 torch fastapi uvicorn[standard] python-multipart

RUN git clone https://github.com/facebookresearch/segment-anything-2.git \
    && cd segment-anything-2 \
    && pip install -e .

RUN cd segment-anything-2/checkpoints \
    && wget https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_small.pt

# Runtime stage
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=builder /workspace/segment-anything-2 /app/segment-anything-2
COPY ./sam2 /app

RUN apt-get update \
    && apt-get install -y \
        python3-pip \
        python-is-python3 \
        libopencv-dev \
        python3-opencv \
    && rm -rf /var/lib/apt/lists/*

CMD ["gunicorn", "-k", "uvicorn_prod_worker.UvicornProdWorker", "main:app", "--bind=0.0.0.0:8000"]
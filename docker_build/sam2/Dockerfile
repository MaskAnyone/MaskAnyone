FROM nvidia/cuda:12.2.2-cudnn8-devel-ubuntu22.04

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

RUN pip3 install \
    numpy==1.24.4 \
    torch \
    fastapi \
    uvicorn[standard] \
    gunicorn \
    python-multipart

RUN git clone https://github.com/facebookresearch/sam2.git \
    && cd sam2 \
    && pip install -e .

RUN cd sam2/checkpoints \
    && wget https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_small.pt

WORKDIR /app

COPY ./sam2 /app

CMD ["gunicorn", "-k", "uvicorn_prod_worker.UvicornProdWorker", "main:app", "--bind=0.0.0.0:8000"]

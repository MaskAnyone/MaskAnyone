# === Build Stage (Full dependencies for compilation) ===
FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-devel AS builder

WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive
ENV TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6+PTX"

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    pkg-config \
    build-essential \
    libffi-dev \
    git \
    wget && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

RUN pip install --upgrade --no-cache-dir pip setuptools

RUN git clone https://github.com/facebookresearch/sam2.git && \
    cd sam2 && \
    # Workarounds to reduce the memory consumption of SAM2 to support long videos (see https://github.com/facebookresearch/sam2/issues/288#issuecomment-2334180449)
    sed -i 's/self.images\[index\] = img/# self.images\[index\] = img/g' ./sam2/utils/misc.py && \
    sed -i 's/self.thread = Thread(target=_load_frames, daemon=True)/# self.thread = Thread(target=_load_frames, daemon=True)/g' ./sam2/utils/misc.py && \
    sed -i 's/self.thread.start()/# self.thread.start()/g' ./sam2/utils/misc.py && \
    SAM2_BUILD_ALLOW_ERRORS=0 pip install -e .

RUN wget -P /workspace/sam2/checkpoints https://dl.fbaipublicfiles.com/segment_anything_2/092824/sam2.1_hiera_small.pt

# === Runtime Stage (Slimmer image) ===
FROM pytorch/pytorch:2.5.1-cuda12.1-cudnn9-runtime

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libavutil-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev && \
    rm -rf /var/lib/apt/lists/*  # Clean up to reduce image size

RUN pip install --upgrade --no-cache-dir \
    fastapi \
    uvicorn[standard] \
    gunicorn \
    python-multipart \
    opencv-python-headless

COPY --from=builder /opt/conda/lib/python3.11/site-packages /opt/conda/lib/python3.11/site-packages
COPY --from=builder /workspace/sam2 /workspace/sam2

ENV PYTHONPATH=/workspace/sam2:$PYTHONPATH

WORKDIR /app

COPY ./sam2 /app

CMD ["gunicorn", "-k", "uvicorn_prod_worker.UvicornProdWorker", "main:app", "--bind=0.0.0.0:8000", "--timeout", "3600"]

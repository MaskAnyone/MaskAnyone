# === Build Stage (Full dependencies for compilation) ===
FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-devel AS builder

WORKDIR /workspace

ARG DEBIAN_FRONTEND=noninteractive
# TORCH_CUDA_ARCH_LIST is injected by setup.sh from `nvidia-smi --query-gpu=compute_cap`.
# Fallback covers Ampere (8.0/8.6), Hopper (9.0), and Blackwell (12.0) with PTX for forward compat.
ARG TORCH_CUDA_ARCH_LIST="8.0;8.6;9.0;12.0+PTX"
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}

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
    # No longer needed, replaced by custom loader below, temporarily keeping it here
    #sed -i 's/self.images\[index\] = img/# self.images\[index\] = img/g' ./sam2/utils/misc.py && \
    #sed -i 's/self.thread = Thread(target=_load_frames, daemon=True)/# self.thread = Thread(target=_load_frames, daemon=True)/g' ./sam2/utils/misc.py && \
    #sed -i 's/self.thread.start()/# self.thread.start()/g' ./sam2/utils/misc.py && \
    SAM2_BUILD_ALLOW_ERRORS=1 pip install -e .

# SAM2_MODELS: comma-separated list of checkpoints to bake in.
# Values: tiny (~46 MB), small (~185 MB), base_plus (~325 MB), large (~898 MB)
# Default matches the original student setup. setup.sh prompts the user at build time.
ARG SAM2_MODELS=small

RUN set -e; \
    BASE="https://dl.fbaipublicfiles.com/segment_anything_2/092824"; \
    for m in $(echo "$SAM2_MODELS" | tr ',' ' '); do \
        wget -P /workspace/sam2/checkpoints "$BASE/sam2.1_hiera_${m}.pt"; \
    done

# === Runtime Stage (Slimmer image) ===
FROM pytorch/pytorch:2.8.0-cuda12.8-cudnn9-runtime

WORKDIR /workspace

RUN pip install --upgrade --no-cache-dir \
    fastapi \
    uvicorn[standard] \
    python-multipart \
    opencv-python-headless \
    decord

COPY --from=builder /opt/conda/lib/python3.11/site-packages /opt/conda/lib/python3.11/site-packages
COPY --from=builder /workspace/sam2 /workspace/sam2

COPY ./sam2_patched_misc.py /workspace/sam2/sam2/utils/misc.py

ENV PYTHONPATH=/workspace/sam2:$PYTHONPATH

WORKDIR /app

FROM python:3.10-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    torch==2.1.0 torchvision==0.16.0 --index-url https://download.pytorch.org/whl/cpu

RUN pip install --no-cache-dir -U openmim && \
    mim install --no-cache-dir "mmengine>=0.10.0" && \
    mim install --no-cache-dir "mmcv>=2.0.1" && \
    mim install --no-cache-dir "mmdet>=3.0.0" && \
    mim install --no-cache-dir "mmpose>=1.3.0"

RUN pip install --no-cache-dir --no-binary xtcocotools --force-reinstall xtcocotools

RUN pip install --no-cache-dir \
    "setuptools<70" \
    fastapi \
    "uvicorn[standard]" \
    gunicorn \
    python-multipart \
    opencv-python-headless

# Pin numpy last — opencv and other packages above can pull in numpy 2.x;
# torch 2.1.0 was compiled against numpy 1.x and will crash at runtime otherwise.
RUN pip install --no-cache-dir --force-reinstall "numpy==1.26.4"

ENV PYTHONPATH=/app:$PYTHONPATH

# Pre-download all RTMPose model checkpoints so first inference is instant.
# Models are baked into the image — no runtime download needed.
RUN python3 -c "\
from mmpose.apis import MMPoseInferencer; \
import numpy as np; \
dummy = np.zeros((64, 64, 3), dtype=np.uint8); \
models = [ \
    'rtmpose-s_8xb256-420e_coco-256x192', \
    'rtmpose-m_8xb256-420e_coco-256x192', \
    'rtmpose-l_8xb256-420e_coco-256x192', \
    'td-hm_hrnet-w32_8xb64-210e_ap10k-256x256', \
]; \
[MMPoseInferencer(m, device='cpu')([dummy], return_vis=False) for m in models]; \
print('All RTMPose models downloaded.')"

WORKDIR /app

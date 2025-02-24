FROM python:3.10-slim AS base

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libpq-dev ffmpeg wget gcc build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu \
    && pip install --no-cache-dir \
        fastapi uvicorn[standard] psycopg2 requests python-jose[cryptography] opencv-python-headless \
        numpy==1.24.4 psutil matplotlib tqdm pandas ultralytics-thop \
    && pip install --no-cache-dir ultralytics==8.3.78 --no-deps

RUN mkdir /backend_models \
    && wget https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11m-pose.pt \
        -O /backend_models/yolo11m-pose.pt

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

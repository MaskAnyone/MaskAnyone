FROM python:3.10-slim AS base

ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1 libpq-dev ffmpeg wget mesa-common-dev libegl1-mesa-dev libgles2-mesa-dev mesa-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir mediapipe==0.10.14 requests opencv-python-headless OneEuroFilter

RUN mkdir /worker_models \
    && wget https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_heavy/float16/latest/pose_landmarker_heavy.task \
        -O /worker_models/pose_landmarker_heavy.task \
    && wget https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task \
        -O /worker_models/face_landmarker.task \
    && wget https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/latest/hand_landmarker.task \
        -O /worker_models/hand_landmarker.task

COPY ./worker /app

WORKDIR /app


# Worker image
FROM base AS worker
CMD ["python3", "/app/worker.py"]

FROM base AS video-masker-core
RUN pip install --no-cache-dir ultralytics==8.3.78 --no-deps
RUN pip install --no-cache-dir psutil matplotlib pandas tqdm pyyaml
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
RUN wget https://github.com/ultralytics/assets/releases/download/v8.3.0/yolo11x-pose.pt -O /worker_models/yolo11x-pose.pt

# API image
FROM video-masker-core AS api
RUN pip install --no-cache-dir fastapi uvicorn[standard] python-multipart 
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8000"]

# CLI image
FROM video-masker-core AS cli
ENTRYPOINT ["python3", "/app/cli.py"]




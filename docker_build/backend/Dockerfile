FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /app

RUN apt-get update \
    && apt-get -y install \
        python3 \
        python3-pip \
        python-is-python3 \
        python3-opencv \
        libgl1 \
        libglib2.0-0 \
        libpq-dev \
        ffmpeg \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install \
        torch \
        torchvision \
        torchaudio --index-url https://download.pytorch.org/whl/cpu \
    && pip install \
        fastapi \
        uvicorn[standard] \
        gunicorn \
        psycopg2 \
        requests \
        python-jose[cryptography] \
    && pip install ultralytics --no-deps \
    && pip install \
        numpy==1.24.4 \
        psutil \
        matplotlib \
        tqdm \
        pandas

COPY ./backend /app

CMD ["gunicorn", "-k", "uvicorn_prod_worker.UvicornProdWorker", "main:app", "--bind=0.0.0.0:8000"]

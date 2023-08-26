FROM python:3.10.0
FROM python:3.10.0
WORKDIR /blender
RUN pip3 install https://files.pythonhosted.org/packages/9c/f3/732e7c6d6c0932b80df488a24e02ac34e8eae14a3c893eb97dcbf6e9c93c/bpy-3.4.0-cp310-cp310-manylinux_2_17_x86_64.whl

RUN apt-get update \
    && apt-get -y install \
    python3 \
    python3-pip \
    python-is-python3 \
    python3-opencv \
    libgl1 \
    libglib2.0-0 \
    libpq-dev \
    gcc \
    libegl1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

COPY BlendArMocap.zip ./
COPY install_addon.py ./

RUN python install_addon.py
RUN pip install \
    requests \
    opencv-python

COPY script.py ./script.py
COPY char_files ./char_files
# Use NVIDIA CUDA container (Ubuntu 22.04)
FROM nvidia/cuda:12.2.2-cudnn8-runtime-ubuntu22.04

COPY requirements.txt /tmp/requirements.txt
COPY pointstowood /opt/PointsToWood/pointstowood

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install basic tools and Python 3.10
RUN apt-get update && apt-get install -y \
    apt-utils git curl vim unzip wget build-essential \
    python3.10 python3.10-distutils python3-pip \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python dependencies
RUN python3.10 -m pip install --upgrade pip

# Install PyTorch first
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

RUN pip install torch-scatter -f https://data.pyg.org/whl/torch-2.5.1+cu121.html \
 && pip install torch-sparse -f https://data.pyg.org/whl/torch-2.5.1+cu121.html \
 && pip install torch-cluster -f https://data.pyg.org/whl/torch-2.5.1+cu121.html \
 && pip install torch-spline-conv -f https://data.pyg.org/whl/torch-2.5.1+cu121.html \
 && pip install torch_geometric -f https://data.pyg.org/whl/torch-2.5.1+cu121.html

RUN python3.10 -m pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt

# Set python and pip to default to Python 3.10
RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip
ENV PYTHON=python3.10
ENV PIP=pip3

# Make sure the script is executable
RUN chmod +x /opt/PointsToWood/pointstowood/predict.py

# Set environment variables
ENV PYTHONPATH=/opt/PointsToWood/pointstowood
ENV PATH=/opt/PointsToWood/pointstowood:$PATH

WORKDIR /opt/PointsToWood/pointstowood
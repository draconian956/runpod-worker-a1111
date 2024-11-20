FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=on \
    SHELL=/bin/bash

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Upgrade apt packages and install required dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
      python3-dev \
      python3-pip \
      fonts-dejavu-core \
      rsync \
      git \
      jq \
      moreutils \
      aria2 \
      wget \
      curl \
      libglib2.0-0 \
      libsm6 \
      libgl1 \
      libxrender1 \
      libxext6 \
      ffmpeg \
      bc \
      libgoogle-perftools4 \
      libtcmalloc-minimal4 \
      procps && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y

# Set Python
RUN ln -s /usr/bin/python3.10 /usr/bin/python

# Install Worker dependencies
RUN pip install requests runpod huggingface_hub

# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./
COPY schemas /schemas

RUN mkdir -p /workspace/stable-diffusion-webui/models/Stable-diffusion/ \
	/workspace/stable-diffusion-webui/models/VAE/ \
	/workspace/stable-diffusion-webui/models/Lora/ \
	/workspace/stable-diffusion-webui/extensions/

COPY ./diffusion_data/mode[l] /workspace/stable-diffusion-webui/models/Stable-diffusion/
COPY ./diffusion_data/va[e] /workspace/stable-diffusion-webui/models/VAE/
COPY ./diffusion_data/lor[a] /workspace/stable-diffusion-webui/models/Lora/

RUN cd /workspace/stable-diffusion-webui/extensions && \
	git clone https://github.com/ljleb/sd-webui-freeu && \
	git clone https://github.com/ashen-sensored/sd_webui_SAG.git && \
	cd /workspace/stable-diffusion-webui && \
	git apply --ignore-whitespace extensions/sd_webui_SAG/automatic1111-CFGDenoiser-and-script_callbacks-mod-for-SAG.patch

# Start the container
RUN chmod +x /start.sh
ENTRYPOINT /start.sh

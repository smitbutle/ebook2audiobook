# Use NVIDIA's CUDA image with Ubuntu 20.04 as the base
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

# Set non-interactive installation to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies, including Python 3.11
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python3.11 \
        python3.11-venv \
        python3.11-dev \
        python3-pip \
        git \
        calibre \
        ffmpeg \
        mecab \
        curl \
        libegl1 \
        libopengl0 \
        libxcb-cursor0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as the default python3
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

# Set the working directory to /app
WORKDIR /app

# Copy all application files into the container
COPY . /app

# Install pip, upgrade it, and perform the editable installation
RUN python3 -m pip install --upgrade pip && \
    pip install -e .

# Create a non-root user for security
RUN useradd -m -u 1000 user

# Switch to the non-root user
USER user

# Define environment variables
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Expose port 7860 for the Gradio application
EXPOSE 7860

# Pre-run app.py in headless mode
RUN python3 app.py --headless

# Specify the command to run your Gradio app
CMD ["python3", "app.py"]

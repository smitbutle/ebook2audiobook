# Use an official NVIDIA CUDA image with cudnn8 and Ubuntu 20.04 as the base
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

# Set non-interactive installation to avoid timezone and other prompts
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies, including Python 3.11 and additional libraries
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y git calibre ffmpeg mecab python3.11 python3.11-venv python3.11-dev curl \
                       libegl1 libopengl0 libxcb-cursor0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set Python 3.11 as the default python3 and install pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1 && \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Set the working directory to /app
WORKDIR /app

# Copy all application files into the container
COPY --chown=user . /app

# Install the pip requirements
RUN pip install -r requirements.txt

# Create a non-root user for security
RUN useradd -m -u 1000 user

# Switch to the non-root user
USER user

# Define environment variables
ENV HOME=/home/user \
    PATH=/home/user/.local/bin:$PATH

# Expose port 7860 for the Gradio application
EXPOSE 7860

# Pre-run app.py to handle pre-requirements
RUN python3 app.py --headless

# Specify the command to run your Gradio app
CMD ["python3", "app.py"]

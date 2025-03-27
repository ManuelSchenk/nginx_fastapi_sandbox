
# For x64 you can use this image as a shortcut (remove the whole RUN pip install poetry block below)
# FROM mwalbeck/python-poetry:2-3.12
# https://hub.docker.com/r/mwalbeck/python-poetry

# The image mwalbeck/python-poetry:2-3.12 does not have an linux/arm/v7 variant published on Docker Hub.
# So to build for ARM (Raspi) we need to use the following as base image:
FROM python:3.10.16-slim-bookworm

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Poetry (not needed if python-poetry image is used for x64)
# Install system dependencies for building poetry
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    libffi-dev \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*
RUN pip install poetry

# Install dependencies
RUN poetry install

# Expose the Hug API port
EXPOSE 3003

# Run the Hug API server
CMD ["poetry", "run", "python", "/app/reverse_proxy/main.py"]
# CMD ["tail", "-f", "/dev/null"]  # for debugging
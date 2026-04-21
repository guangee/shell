FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1
WORKDIR /app

# OpenCV runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libglib2.0-0 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install minimal runtime dependencies for app.py
RUN pip install --upgrade pip && pip install \
    fastapi \
    "uvicorn[standard]" \
    ultralytics \
    opencv-python-headless \
    numpy \
    python-multipart
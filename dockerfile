FROM python:3.15.1-alpine@sha256:54448f67d7c31c39e5cdd3ea2d6382395ce142806c284425f8e897d78a0465b3

# Install system dependencies
RUN apk add --no-cache \
    curl \
    ca-certificates \
    findutils \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Install only the Python dependency needed by mitene_download.py
RUN pip install --no-cache-dir aiohttp && \
    pip cache purge

# Copy your custom mitene_download.py script
COPY mitene_download.py /app/mitene_download.py

# Copy and set up entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

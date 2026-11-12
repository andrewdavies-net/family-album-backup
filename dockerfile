FROM python:3.15.2-alpine@sha256:0f9552bb28711333da16915ec146f5e6bb44a7fdac9ced15dc17c2e0206346dd

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

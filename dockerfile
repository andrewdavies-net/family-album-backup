FROM python:3.14.10-alpine@sha256:5862d971d1f0ae26b258cefa4e893556b1d3aba81bd2ff30888704ad378bab67

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

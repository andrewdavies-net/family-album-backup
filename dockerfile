FROM python:3.14.4-alpine@sha256:dd4d2bd5b53d9b25a51da13addf2be586beebd5387e289e798e4083d94ca837a

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

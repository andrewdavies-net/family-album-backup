FROM python:3.13.9-alpine@sha256:e5fa639e49b85986c4481e28faa2564b45aa8021413f31026c3856e5911618b1

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

FROM python:3.13.3-alpine3.20

# Install everything as root first
RUN apk add --no-cache \
    git \
    curl \
    ca-certificates \
    findutils && \
    rm -rf /var/cache/apk/*

RUN pip install --no-cache-dir mitene_download && \
    pip cache purge

WORKDIR /app

# Create backup directory (nobody will need write access via fsGroup)
RUN mkdir -p /backup

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to nobody:nogroup (65534:65534)
USER nobody:nogroup

ENV OUTPUT_DIR=/backup

ENTRYPOINT ["/entrypoint.sh"]

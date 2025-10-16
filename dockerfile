FROM python:3.13.3-alpine3.20

# Install everything as root first
RUN apk add --no-cache \
    git \
    curl \
    ca-certificates \
    findutils && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy requirements first (better Docker layer caching)
COPY requirements.txt .

# Install Python dependencies with pinned versions
RUN pip install --no-cache-dir -r requirements.txt && \
    pip cache purge

# Create backup directory (nobody will need write access via fsGroup)
RUN mkdir -p /backup

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to nobody:nogroup (65534:65534)
USER nobody:nogroup

ENV OUTPUT_DIR=/backup

ENTRYPOINT ["/entrypoint.sh"]

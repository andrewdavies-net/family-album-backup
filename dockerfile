FROM python:3.13.9-alpine@sha256:e5fa639e49b85986c4481e28faa2564b45aa8021413f31026c3856e5911618b1

# Install system dependencies including build tools
RUN apk add --no-cache \
    git \
    curl \
    ca-certificates \
    findutils \
    gcc \
    musl-dev \
    python3-dev \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Install Python dependencies first (better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && \
    pip cache purge

# Copy and set up entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r$//' /entrypoint.sh && chmod +x /entrypoint.sh

# Copy application code
COPY . .

ENTRYPOINT ["/entrypoint.sh"]

FROM python:3.14.0-alpine@sha256:8373231e1e906ddfb457748bfc032c4c06ada8c759b7b62d9c73ec2a3c56e710

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

FROM python:3.14.0-alpine@sha256:8373231e1e906ddfb457748bfc032c4c06ada8c759b7b62d9c73ec2a3c56e710

# Install runtime dependencies
RUN apk add --no-cache git curl ca-certificates findutils

# Install build dependencies temporarily
RUN apk add --no-cache --virtual .build-deps \
    gcc \
    musl-dev \
    python3-dev

WORKDIR /app

COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    pip cache purge

# Remove build dependencies to keep image small
RUN apk del .build-deps

COPY . .

CMD ["python", "main.py"]

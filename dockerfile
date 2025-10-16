FROM python:3.11.10-alpine3.20

WORKDIR /app

RUN apk add --no-cache \
    git \
    curl \
    ca-certificates

RUN pip install --no-cache-dir mitene_download

RUN mkdir -p /backup

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV OUTPUT_DIR=/backup

ENTRYPOINT ["/entrypoint.sh"]

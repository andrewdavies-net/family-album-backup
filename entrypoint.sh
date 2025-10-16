#!/bin/sh

OUTPUT_DIR=${OUTPUT_DIR:-/backup}
URL=${MITENE_URL}
PASSWORD=${MITENE_PASSWORD}
NO_COMMENTS=${NO_COMMENTS:-false}

if [ -z "$URL" ]; then
    echo "Error: MITENE_URL environment variable is required"
    exit 1
fi

cd "$OUTPUT_DIR"

CMD="mitene_download $URL"

if [ -n "$PASSWORD" ]; then
    CMD="$CMD --password $PASSWORD"
fi

if [ "$NO_COMMENTS" = "true" ]; then
    CMD="$CMD --nocomments"
fi

echo "Starting backup to: $OUTPUT_DIR"
echo "URL: $URL"
echo "No comments: $NO_COMMENTS"
echo "Timestamp: $(date)"

exec $CMD

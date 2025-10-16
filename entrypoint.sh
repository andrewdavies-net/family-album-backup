#!/bin/sh

OUTPUT_DIR=${OUTPUT_DIR:-/backup}
URL=${MITENE_URL}
PASSWORD=${MITENE_PASSWORD}
NO_COMMENTS=${NO_COMMENTS:-false}
DISCORD_WEBHOOK=${DISCORD_WEBHOOK_URL}
ENABLE_DISCORD=${ENABLE_DISCORD_WEBHOOK:-false}

if [ -z "$URL" ]; then
    echo "Error: MITENE_URL environment variable is required"
    exit 1
fi

cd "$OUTPUT_DIR"

# Function to count files by extension
count_files() {
    echo "📊 File Summary:"
    echo "=================="
    
    # Count different file types
    IMAGES=$(find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.heic" \) | wc -l)
    VIDEOS=$(find . -type f \( -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.webm" -o -iname "*.m4v" \) | wc -l)
    COMMENTS=$(find . -type f -iname "*.md" | wc -l)
    OTHER=$(find . -type f ! \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" -o -iname "*.webp" -o -iname "*.heic" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.avi" -o -iname "*.mkv" -o -iname "*.webm" -o -iname "*.m4v" -o -iname "*.md" \) | wc -l)
    TOTAL=$(find . -type f | wc -l)
    
    echo "📸 Images:   $IMAGES"
    echo "🎬 Videos:   $VIDEOS"
    echo "📝 Comments: $COMMENTS"
    echo "📄 Other:    $OTHER"
    echo "📁 Total:    $TOTAL"
    echo "=================="
    
    # Store counts for Discord webhook
    export FILE_IMAGES=$IMAGES
    export FILE_VIDEOS=$VIDEOS
    export FILE_COMMENTS=$COMMENTS
    export FILE_OTHER=$OTHER
    export FILE_TOTAL=$TOTAL
}

# Function to send Discord notification
send_discord_notification() {
    local status=$1
    local message=$2
    local color=$3
    
    if [ "$ENABLE_DISCORD" = "true" ] && [ -n "$DISCORD_WEBHOOK" ]; then
        local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
        
        # Create JSON payload
        local payload=$(cat <<EOF
{
  "embeds": [
    {
      "title": "📱 Family Album Backup",
      "description": "$message",
      "color": $color,
      "timestamp": "$timestamp",
      "fields": [
        {
          "name": "📸 Images",
          "value": "${FILE_IMAGES:-0}",
          "inline": true
        },
        {
          "name": "🎬 Videos", 
          "value": "${FILE_VIDEOS:-0}",
          "inline": true
        },
        {
          "name": "📝 Comments",
          "value": "${FILE_COMMENTS:-0}",
          "inline": true
        },
        {
          "name": "📁 Total Files",
          "value": "${FILE_TOTAL:-0}",
          "inline": false
        },
        {
          "name": "🔗 Album URL",
          "value": "${URL}",
          "inline": false
        }
      ],
      "footer": {
        "text": "Mitene Backup Bot"
      }
    }
  ]
}
EOF
        )
        
        echo "📤 Sending Discord notification..."
        curl -X POST "$DISCORD_WEBHOOK" \
            -H "Content-Type: application/json" \
            -d "$payload" \
            --silent --show-error || echo "⚠️  Failed to send Discord notification"
    fi
}

# Build command
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
echo "Discord notifications: $ENABLE_DISCORD"
echo "Timestamp: $(date)"

# Count files before backup
echo ""
echo "📊 Files before backup:"
count_files
INITIAL_TOTAL=$FILE_TOTAL

# Send start notification
send_discord_notification "started" "🚀 Backup started for family album" "3447003"

# Run the backup
echo ""
echo "🔄 Running backup..."
if $CMD; then
    BACKUP_STATUS="success"
    echo "✅ Backup completed successfully!"
else
    BACKUP_STATUS="failed"
    echo "❌ Backup failed!"
fi

echo ""
echo "📊 Files after backup:"
count_files

# Calculate new files
NEW_FILES=$((FILE_TOTAL - INITIAL_TOTAL))
echo "📥 New files downloaded: $NEW_FILES"

# Send completion notification
if [ "$BACKUP_STATUS" = "success" ]; then
    if [ "$NEW_FILES" -gt 0 ]; then
        send_discord_notification "success" "✅ Backup completed successfully! Downloaded $NEW_FILES new files." "5763719"
    else
        send_discord_notification "success" "✅ Backup completed successfully! No new files found." "5763719"
    fi
    exit 0
else
    send_discord_notification "failed" "❌ Backup failed! Please check the logs." "15158332"
    exit 1
fi

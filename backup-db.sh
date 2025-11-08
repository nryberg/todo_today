#!/bin/bash

# SQLite Database Backup Script for MinIO
# This script backs up the SQLite database to MinIO S3-compatible storage

set -e  # Exit on any error

# Load environment file if it exists
if [ -f "backup.env" ]; then
    echo "Loading configuration from backup.env..."
    export $(grep -v '^#' backup.env | xargs)
elif [ -f "/app/backup.env" ]; then
    echo "Loading configuration from /app/backup.env..."
    export $(grep -v '^#' /app/backup.env | xargs)
fi

# Configuration
MINIO_ENDPOINT="${MINIO_ENDPOINT:-http://minio:9000}"
MINIO_ACCESS_KEY="${MINIO_ACCESS_KEY}"
MINIO_SECRET_KEY="${MINIO_SECRET_KEY}"
MINIO_BUCKET="${MINIO_BUCKET:-todo-backups}"
DB_PATH="${DB_PATH:-}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-30}"

# Generate backup filename with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILENAME="todo_backup_${TIMESTAMP}.sqlite3"
TEMP_BACKUP_PATH="/tmp/${BACKUP_FILENAME}"

echo "Starting database backup at $(date)"

# Auto-detect database file if not specified
if [ -z "$DB_PATH" ]; then
    echo "Auto-detecting database file using Rails configuration..."

    # Try to get the database path from Rails
    if command -v rails &> /dev/null; then
        RAILS_DB_PATH=$(cd /app && rails runner "puts Rails.application.config.database_configuration[Rails.env]['database']" 2>/dev/null || echo "")
        if [ -n "$RAILS_DB_PATH" ]; then
            # Convert relative path to absolute if needed
            if [[ "$RAILS_DB_PATH" != /* ]]; then
                DB_PATH="/app/$RAILS_DB_PATH"
            else
                DB_PATH="$RAILS_DB_PATH"
            fi
            echo "Rails reports database at: $DB_PATH"
        fi
    fi

    # Fallback to manual detection if Rails method failed
    if [ -z "$DB_PATH" ] || [ ! -f "$DB_PATH" ]; then
        echo "Rails detection failed, trying manual detection..."
        if [ -f "/app/db/production.sqlite3" ]; then
            DB_PATH="/app/db/production.sqlite3"
            echo "Found production database: $DB_PATH"
        elif [ -f "/app/db/development.sqlite3" ]; then
            DB_PATH="/app/db/development.sqlite3"
            echo "Found development database: $DB_PATH"
        else
            echo "ERROR: No SQLite database found. Listing /app/db/ contents:"
            ls -la /app/db/ || echo "Cannot list /app/db/ directory"
            exit 1
        fi
    fi
fi

# Check if database file exists
if [ ! -f "$DB_PATH" ]; then
    echo "ERROR: Database file not found at $DB_PATH"
    echo "Available files in database directory:"
    ls -la "$(dirname "$DB_PATH")" || echo "Cannot list database directory"
    exit 1
fi

# Display the database file being backed up
echo "Backing up database: $DB_PATH"
DB_SIZE=$(du -h "$DB_PATH" | cut -f1)
echo "Database size: $DB_SIZE"

# Check required environment variables
if [ -z "$MINIO_ACCESS_KEY" ] || [ -z "$MINIO_SECRET_KEY" ]; then
    echo "ERROR: MINIO_ACCESS_KEY and MINIO_SECRET_KEY must be set"
    exit 1
fi

# Install mc (MinIO client) if not present
if ! command -v mc &> /dev/null; then
    echo "Installing MinIO client..."
    curl -o /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x /usr/local/bin/mc
fi

# Configure MinIO client
echo "Configuring MinIO client..."
mc alias set minio "$MINIO_ENDPOINT" "$MINIO_ACCESS_KEY" "$MINIO_SECRET_KEY"

# Test connection
echo "Testing MinIO connection..."
if ! mc ls minio/ > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to MinIO server at $MINIO_ENDPOINT"
    exit 1
fi

# Create bucket if it doesn't exist
echo "Ensuring bucket exists..."
if ! mc ls "minio/$MINIO_BUCKET" > /dev/null 2>&1; then
    echo "Creating bucket: $MINIO_BUCKET"
    mc mb "minio/$MINIO_BUCKET"
else
    echo "Bucket $MINIO_BUCKET already exists"
fi

# Create a consistent backup using SQLite's backup command
echo "Creating database backup..."
sqlite3 "$DB_PATH" ".backup '$TEMP_BACKUP_PATH'"

# Verify backup was created
if [ ! -f "$TEMP_BACKUP_PATH" ]; then
    echo "ERROR: Backup file was not created"
    exit 1
fi

# Get file size for logging
BACKUP_SIZE=$(du -h "$TEMP_BACKUP_PATH" | cut -f1)
echo "Backup created: $BACKUP_FILENAME ($BACKUP_SIZE)"

# Upload to MinIO
echo "Uploading backup to MinIO..."
if mc cp "$TEMP_BACKUP_PATH" "minio/$MINIO_BUCKET/$BACKUP_FILENAME"; then
    echo "Backup uploaded successfully: s3://$MINIO_BUCKET/$BACKUP_FILENAME"
else
    echo "ERROR: Failed to upload backup to MinIO"
    rm -f "$TEMP_BACKUP_PATH"
    exit 1
fi

# Clean up temporary file
rm -f "$TEMP_BACKUP_PATH"
echo "Temporary backup file cleaned up"

# Clean up old backups (optional)
if [ "$BACKUP_RETENTION_DAYS" -gt 0 ]; then
    echo "Cleaning up backups older than $BACKUP_RETENTION_DAYS days..."
    CUTOFF_DATE=$(date -d "$BACKUP_RETENTION_DAYS days ago" +"%Y%m%d")

    # List and delete old backups
    mc ls "minio/$MINIO_BUCKET/" | grep "todo_backup_" | while read -r line; do
        # Extract date from filename (format: todo_backup_YYYYMMDD_HHMMSS.sqlite3)
        BACKUP_DATE=$(echo "$line" | sed -n 's/.*todo_backup_\([0-9]\{8\}\)_.*/\1/p')
        if [ -n "$BACKUP_DATE" ] && [ "$BACKUP_DATE" -lt "$CUTOFF_DATE" ]; then
            OLD_BACKUP=$(echo "$line" | awk '{print $NF}')
            echo "Deleting old backup: $OLD_BACKUP"
            mc rm "minio/$MINIO_BUCKET/$OLD_BACKUP"
        fi
    done
fi

# Create a "latest" symlink for easy access
echo "Creating latest backup reference..."
mc cp "minio/$MINIO_BUCKET/$BACKUP_FILENAME" "minio/$MINIO_BUCKET/latest.sqlite3"

echo "Backup completed successfully at $(date)"
echo "Backup location: s3://$MINIO_BUCKET/$BACKUP_FILENAME"
echo "Latest backup: s3://$MINIO_BUCKET/latest.sqlite3"

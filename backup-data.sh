#!/bin/bash
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creating backup in $BACKUP_DIR"

# Backup database
if [ -f "db/production.sqlite3" ]; then
    cp db/production.sqlite3 "$BACKUP_DIR/"
    echo "✅ Database backed up"
fi

# Backup logs (last 7 days only to save space)
if [ -d "log" ]; then
    find log -name "*.log" -mtime -7 -exec cp {} "$BACKUP_DIR/" \;
    echo "✅ Recent logs backed up"
fi

# Backup storage
if [ -d "storage" ]; then
    cp -r storage "$BACKUP_DIR/"
    echo "✅ Storage files backed up"
fi

echo "🎉 Backup complete: $BACKUP_DIR"

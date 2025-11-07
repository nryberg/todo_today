#!/bin/bash

echo "🔄 Todo Today Data Restore Script"
echo "================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if backup directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <backup_directory>"
    echo ""
    echo "Available backups:"
    if [ -d "backups" ]; then
        ls -la backups/ | grep "^d" | awk '{print "  " $9}' | grep -v "^\.$\|^\.\.$"
    else
        echo "  No backups directory found"
    fi
    exit 1
fi

BACKUP_DIR="$1"

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    print_error "Backup directory does not exist: $BACKUP_DIR"
    exit 1
fi

print_status "Restoring from backup: $BACKUP_DIR"

# Check if containers are running and warn user
if command -v docker &> /dev/null; then
    if docker compose ps | grep -q "Up"; then
        print_warning "Docker containers are currently running!"
        print_status "It's recommended to stop containers before restoring data."
        echo ""
        read -p "Stop containers now? (y/N): " -r
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Stopping containers..."
            docker compose down
            print_success "Containers stopped"
        else
            print_warning "Continuing with containers running (may cause issues)"
        fi
    fi
fi

echo ""
print_status "Starting restore process..."

# Create directories if they don't exist
mkdir -p db log storage tmp

# Restore database
if [ -f "$BACKUP_DIR/production.sqlite3" ]; then
    if [ -f "db/production.sqlite3" ]; then
        print_warning "Existing database found - creating backup..."
        cp db/production.sqlite3 "db/production.sqlite3.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Existing database backed up"
    fi

    cp "$BACKUP_DIR/production.sqlite3" db/
    print_success "Database restored"
else
    print_warning "No database file found in backup directory"
fi

# Restore logs
LOG_FILES=$(find "$BACKUP_DIR" -name "*.log" 2>/dev/null | wc -l)
if [ "$LOG_FILES" -gt 0 ]; then
    cp "$BACKUP_DIR"/*.log log/ 2>/dev/null || true
    print_success "Restored $LOG_FILES log files"
else
    print_status "No log files found in backup"
fi

# Restore storage directory
if [ -d "$BACKUP_DIR/storage" ]; then
    if [ -d "storage" ] && [ "$(ls -A storage 2>/dev/null)" ]; then
        print_warning "Existing storage directory found - creating backup..."
        mv storage "storage.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Existing storage directory backed up"
    fi

    cp -r "$BACKUP_DIR/storage" ./
    print_success "Storage directory restored"
else
    print_status "No storage directory found in backup"
fi

# Set proper permissions
chmod 755 db log storage tmp 2>/dev/null || true
chmod 644 db/*.sqlite3 2>/dev/null || true

print_success "File permissions set"

echo ""
print_status "Restore Summary:"
echo "================"

# Check what was restored
if [ -f "db/production.sqlite3" ]; then
    DB_SIZE=$(du -h db/production.sqlite3 | cut -f1)
    print_success "Database: $DB_SIZE (db/production.sqlite3)"

    # Show basic stats if sqlite3 is available
    if command -v sqlite3 &> /dev/null; then
        TASK_COUNT=$(sqlite3 db/production.sqlite3 "SELECT COUNT(*) FROM tasks;" 2>/dev/null || echo "N/A")
        COMPLETION_COUNT=$(sqlite3 db/production.sqlite3 "SELECT COUNT(*) FROM task_completions;" 2>/dev/null || echo "N/A")
        echo "   • Tasks: $TASK_COUNT"
        echo "   • Completions: $COMPLETION_COUNT"
    fi
fi

LOG_COUNT=$(find log -name "*.log" 2>/dev/null | wc -l)
if [ "$LOG_COUNT" -gt 0 ]; then
    print_success "Logs: $LOG_COUNT files"
fi

if [ -d "storage" ]; then
    STORAGE_FILES=$(find storage -type f 2>/dev/null | wc -l)
    print_success "Storage: $STORAGE_FILES files"
fi

echo ""
print_success "🎉 Restore completed successfully!"
echo ""
print_status "Next steps:"
echo "==========="
echo "1. Start your containers: docker compose up -d"
echo "2. Check that your data is accessible in the app"
echo "3. Create a new backup after confirming everything works"
echo ""
print_warning "💡 Tip: The original files were backed up with timestamps if they existed"

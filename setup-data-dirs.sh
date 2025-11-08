#!/bin/bash

echo "📁 Setting up persistent data directories for Todo Today"
echo "======================================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Create data directories on host machine
DIRS=(
    "db"
    "log"
    "storage"
    "tmp"
    "tmp/pids"
    "tmp/cache"
)

print_status "Creating persistent data directories..."

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        print_success "Created: $dir"
    else
        print_status "Already exists: $dir"
    fi
done

# Set proper permissions
print_status "Setting directory permissions..."
chmod 755 db log storage tmp
chmod 755 tmp/pids tmp/cache

# Create .keep files for empty directories (Git compatibility)
KEEP_DIRS=("log" "tmp" "tmp/pids" "tmp/cache" "storage")
for dir in "${KEEP_DIRS[@]}"; do
    if [ ! -f "$dir/.keep" ]; then
        touch "$dir/.keep"
        print_success "Created .keep file in $dir"
    fi
done

# Display current data status
echo ""
print_status "Checking existing data..."

if [ -f "db/production.sqlite3" ]; then
    DB_SIZE=$(du -h db/production.sqlite3 | cut -f1)
    print_success "Database exists: $DB_SIZE (db/production.sqlite3)"

    # Show basic stats if sqlite3 is available
    if command -v sqlite3 &> /dev/null; then
        TASK_COUNT=$(sqlite3 db/production.sqlite3 "SELECT COUNT(*) FROM tasks;" 2>/dev/null || echo "N/A")
        COMPLETION_COUNT=$(sqlite3 db/production.sqlite3 "SELECT COUNT(*) FROM task_completions;" 2>/dev/null || echo "N/A")
        echo "   • Tasks: $TASK_COUNT"
        echo "   • Completions: $COMPLETION_COUNT"
    fi
else
    print_warning "No database file found (will be created on first run)"
fi

# Check log files
LOG_FILES=$(find log -name "*.log" 2>/dev/null | wc -l)
if [ "$LOG_FILES" -gt 0 ]; then
    print_success "Found $LOG_FILES log files in log/"
    LOG_SIZE=$(du -sh log 2>/dev/null | cut -f1 || echo "0")
    echo "   • Log directory size: $LOG_SIZE"
fi

# Check storage
STORAGE_FILES=$(find storage -type f 2>/dev/null | wc -l)
if [ "$STORAGE_FILES" -gt 0 ]; then
    print_success "Found $STORAGE_FILES files in storage/"
fi

echo ""
print_status "Volume mount verification..."
echo "The following directories will be mounted to preserve data:"
echo ""
echo "Host Directory    → Container Path    → Purpose"
echo "─────────────────────────────────────────────────────────"
echo "./db              → /app/db           → SQLite database files"
echo "./log             → /app/log          → Application logs"
echo "./storage         → /app/storage      → File uploads/assets"
echo "./tmp             → /app/tmp          → Temporary files & PIDs"

echo ""
print_success "✨ Data directories are ready!"
echo ""
print_status "💡 Data Persistence Info:"
echo "========================="
echo "• Your database will be saved in: $(pwd)/db/"
echo "• Logs will be saved in: $(pwd)/log/"
echo "• Even after 'docker compose down' and rebuilds, your data persists"
echo "• To backup your data: cp -r db/ db_backup_$(date +%Y%m%d)/"
echo "• To restore data: stop containers, copy backup to db/, restart"
echo ""

# Create a simple backup script
cat > backup-data.sh << 'EOF'
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
EOF

chmod +x backup-data.sh
print_success "Created backup script: ./backup-data.sh"

echo ""
print_warning "🚨 Important Notes:"
echo "==================="
echo "• Always stop containers before manual database operations"
echo "• Use 'docker compose down' to stop, 'docker compose up -d' to start"
echo "• Your data in ./db/ ./log/ ./storage/ ./tmp/ will persist across rebuilds"
echo "• Run './backup-data.sh' regularly to create backups"

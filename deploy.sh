#!/bin/bash

# deploy.sh - Deploy Todo Today to bigbox server
# Usage: ./deploy.sh [remote-path]

set -e

# Configuration
REMOTE_HOST="bigbox"
REMOTE_USER="${REMOTE_USER:-$(whoami)}"
REMOTE_PATH="${1:-/home/${REMOTE_USER}/apps/todo_today}"
LOCAL_PATH="$(pwd)"
APP_NAME="todo_today"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Gemfile" ] || [ ! -f "docker-compose.yml" ]; then
    log_error "This script must be run from the todo_today project root directory"
    exit 1
fi

# Check if bigbox is reachable
log_info "Checking connectivity to ${REMOTE_HOST}..."
if ! ssh -o ConnectTimeout=5 "${REMOTE_USER}@${REMOTE_HOST}" "echo 'Connected'" > /dev/null 2>&1; then
    log_error "Cannot connect to ${REMOTE_HOST}. Please check your SSH configuration."
    exit 1
fi
log_success "Connected to ${REMOTE_HOST}"

# Find an open port on the remote server
log_info "Finding an open port on ${REMOTE_HOST}..."
OPEN_PORT=$(ssh "${REMOTE_USER}@${REMOTE_HOST}" 'bash -s' << 'ENDSSH'
# Function to check if a port is in use
port_is_free() {
    ! ss -tuln | grep -q ":$1 "
}

# Try ports starting from 3000
for port in {3000..3100}; do
    if port_is_free $port; then
        echo $port
        exit 0
    fi
done

# If no port found in that range, try 8000-8100
for port in {8000..8100}; do
    if port_is_free $port; then
        echo $port
        exit 0
    fi
done

echo "0"
ENDSSH
)

if [ "$OPEN_PORT" = "0" ]; then
    log_error "Could not find an open port on ${REMOTE_HOST}"
    exit 1
fi

log_success "Found open port: ${OPEN_PORT}"

# Update .env file with the port
log_info "Updating .env with port ${OPEN_PORT}..."
if [ -f ".env" ]; then
    # Update APP_PORT if it exists, otherwise add it
    if grep -q "^APP_PORT=" .env; then
        sed -i.bak "s/^APP_PORT=.*/APP_PORT=${OPEN_PORT}/" .env
    else
        echo "APP_PORT=${OPEN_PORT}" >> .env
    fi
    rm -f .env.bak
else
    log_error ".env file not found. Please create it from .env.example"
    exit 1
fi

# Create remote directory if it doesn't exist
log_info "Creating remote directory ${REMOTE_PATH}..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ${REMOTE_PATH}"

# Rsync the application
log_info "Syncing application files to ${REMOTE_HOST}:${REMOTE_PATH}..."
rsync -avz --progress \
    --exclude='.git' \
    --exclude='log/*' \
    --exclude='tmp/*' \
    --exclude='storage/*' \
    --exclude='node_modules' \
    --exclude='.env.bak' \
    "${LOCAL_PATH}/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

log_success "Files synced successfully"

# Deploy on remote server
log_info "Building and starting Docker containers on ${REMOTE_HOST}..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" "cd ${REMOTE_PATH} && bash -s" << 'ENDSSH'
set -e

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running or you don't have permission to access it"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: docker-compose is not installed"
    exit 1
fi

# Stop existing containers if running
echo "Stopping existing containers (if any)..."
docker-compose down 2>/dev/null || true

# Build and start services
echo "Building Docker image..."
docker-compose build --no-cache

echo "Starting services..."
docker-compose up -d

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 10

# Show status
echo ""
echo "=== Deployment Status ==="
docker-compose ps

# Show logs
echo ""
echo "=== Recent Logs ==="
docker-compose logs --tail=20
ENDSSH

if [ $? -eq 0 ]; then
    log_success "Deployment completed successfully!"
    echo ""
    echo "========================================"
    echo "  Deployment Summary"
    echo "========================================"
    echo "  Server: ${REMOTE_HOST}"
    echo "  Path: ${REMOTE_PATH}"
    echo "  Port: ${OPEN_PORT}"
    echo ""
    echo "  Access via Tailscale: http://todo-today:${OPEN_PORT}"
    echo "  Access via bigbox: http://bigbox:${OPEN_PORT}"
    echo ""
    echo "  View logs: ssh ${REMOTE_USER}@${REMOTE_HOST} 'cd ${REMOTE_PATH} && docker-compose logs -f'"
    echo "  Restart: ssh ${REMOTE_USER}@${REMOTE_HOST} 'cd ${REMOTE_PATH} && docker-compose restart'"
    echo "  Stop: ssh ${REMOTE_USER}@${REMOTE_HOST} 'cd ${REMOTE_PATH} && docker-compose down'"
    echo "========================================"
else
    log_error "Deployment failed. Check the logs above for details."
    exit 1
fi

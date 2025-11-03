#!/bin/bash

echo "🔍 Todo Today Diagnostic Script"
echo "=============================="
echo ""

# Color codes
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Docker status
print_status "Checking Docker environment..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    exit 1
else
    print_success "Docker is installed: $(docker --version)"
fi

if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running"
    exit 1
else
    print_success "Docker daemon is running"
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
    print_success "docker-compose found: $(docker-compose --version)"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
    print_success "docker compose found: $(docker compose version)"
else
    print_error "Neither docker-compose nor docker compose is available"
    exit 1
fi

echo ""
print_status "Checking project files..."

# Check important files
files_to_check=(
    "Gemfile"
    "Gemfile.lock"
    "config/application.rb"
    "config/database.yml"
    "docker-compose.yml"
)

for file in "${files_to_check[@]}"; do
    if [ -f "$file" ]; then
        print_success "$file exists"
    else
        print_error "$file missing"
    fi
done

# Check .env file
if [ -f ".env" ]; then
    print_success ".env file exists"
    echo "Environment variables:"
    grep -v "SECRET_KEY_BASE\|PASSWORD" .env | while read line; do
        echo "  $line"
    done
    if grep -q "SECRET_KEY_BASE=" .env; then
        print_success "SECRET_KEY_BASE is configured"
    else
        print_warning "SECRET_KEY_BASE not found in .env"
    fi
else
    print_warning ".env file does not exist"
fi

echo ""
print_status "Checking Docker containers..."

# Container status
$DOCKER_COMPOSE ps

echo ""
print_status "Recent container logs (last 20 lines)..."
echo "========================================"
$DOCKER_COMPOSE logs --tail=20 web

echo ""
print_status "Checking system resources..."
echo "Available disk space:"
df -h . | tail -1

echo ""
echo "Memory usage:"
free -h 2>/dev/null || echo "Memory info not available"

echo ""
print_status "Docker system information..."
echo "Images:"
docker images | grep todo_today || echo "No todo_today images found"

echo ""
echo "Container details:"
docker ps -a | grep todo_today || echo "No todo_today containers found"

echo ""
print_status "Troubleshooting suggestions..."
echo "=============================="

# Check if container is restarting
if $DOCKER_COMPOSE ps | grep -q "Restarting"; then
    print_warning "Container is restarting - check logs above for errors"
    echo "Common fixes:"
    echo "  1. Check SECRET_KEY_BASE in .env file"
    echo "  2. Verify database permissions: ls -la db/"
    echo "  3. Try rebuilding: $DOCKER_COMPOSE build --no-cache"
    echo "  4. Check available disk space"
fi

# Check if container is not found
if ! $DOCKER_COMPOSE ps | grep -q "web"; then
    print_warning "Container not found - try starting:"
    echo "  $DOCKER_COMPOSE up -d"
fi

echo ""
echo "🔧 Useful commands:"
echo "=================="
echo "View live logs:     $DOCKER_COMPOSE logs -f web"
echo "Rebuild container:  $DOCKER_COMPOSE build --no-cache"
echo "Restart services:   $DOCKER_COMPOSE restart"
echo "Stop all:          $DOCKER_COMPOSE down"
echo "Clean system:      docker system prune -f"
echo "Shell into container: $DOCKER_COMPOSE exec web bash"
echo ""

print_success "Diagnostic complete!"

#!/bin/bash
set -e

echo "🐳 Todo Today Docker Build Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    print_error "Neither docker-compose nor docker compose is available."
    exit 1
fi

print_status "Using: $DOCKER_COMPOSE"

# Set up persistent data directories
print_status "Setting up persistent data directories..."
if [ -f "./setup-data-dirs.sh" ]; then
    ./setup-data-dirs.sh
else
    # Fallback: create directories manually
    mkdir -p db log storage tmp tmp/pids tmp/cache
    chmod 755 db log storage tmp tmp/pids tmp/cache
    print_success "Data directories created"
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    print_status "Creating .env file from template..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_success ".env file created from .env.example"
    else
        print_warning ".env.example not found, creating minimal .env file"
        cat > .env << EOF
RAILS_ENV=production
SECRET_KEY_BASE=$(openssl rand -hex 64)
SEED_DB=true
APP_HOST=bigbox
APP_PORT=3000
EOF
    fi
else
    print_status ".env file already exists"
fi

# Generate SECRET_KEY_BASE if not set
if ! grep -q "SECRET_KEY_BASE=" .env || grep -q "SECRET_KEY_BASE=$" .env || grep -q "SECRET_KEY_BASE=your_secret_key_base_here" .env; then
    print_status "Generating SECRET_KEY_BASE..."
    SECRET_KEY=$(openssl rand -hex 64)

    # Remove existing SECRET_KEY_BASE line and add new one
    sed -i.bak '/^SECRET_KEY_BASE=/d' .env
    echo "SECRET_KEY_BASE=$SECRET_KEY" >> .env
    rm -f .env.bak

    print_success "SECRET_KEY_BASE generated and added to .env"
else
    print_status "SECRET_KEY_BASE already configured"
fi

# Set Google OAuth feature flag if not set
if ! grep -q "ENABLE_GOOGLE_OAUTH=" .env; then
    print_status "Setting Google OAuth feature flag to disabled by default..."
    echo "ENABLE_GOOGLE_OAUTH=false" >> .env
    print_success "Google OAuth disabled by default (can be enabled later)"
else
    OAUTH_STATUS=$(grep "ENABLE_GOOGLE_OAUTH=" .env | cut -d'=' -f2)
    if [ "$OAUTH_STATUS" = "true" ]; then
        print_success "Google OAuth is enabled"
    else
        print_success "Google OAuth is disabled"
    fi
fi

# Handle Gemfile.lock platform and Bundler version issues
print_status "Checking Gemfile.lock platforms and Bundler version..."
if [ -f Gemfile.lock ]; then
    # Check Bundler version
    BUNDLER_VERSION=$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -1 | xargs)
    if [ -n "$BUNDLER_VERSION" ]; then
        print_status "Gemfile.lock uses Bundler version: $BUNDLER_VERSION"
    else
        print_warning "Could not detect Bundler version from Gemfile.lock"
    fi

    # Check platforms
    if grep -q "x86_64-linux" Gemfile.lock; then
        print_success "Linux platform already supported in Gemfile.lock"
    else
        print_warning "Adding Linux platform support to Gemfile.lock..."
        if command -v bundle &> /dev/null; then
            # Update Bundler if needed
            if [ -n "$BUNDLER_VERSION" ]; then
                print_status "Installing Bundler $BUNDLER_VERSION locally..."
                gem install bundler:$BUNDLER_VERSION 2>/dev/null || print_warning "Could not install specific Bundler version"
            fi

            bundle lock --add-platform x86_64-linux
            print_success "Added x86_64-linux platform to Gemfile.lock"
        else
            print_warning "Bundler not found locally. Docker will handle platform differences."
        fi
    fi
else
    print_warning "Gemfile.lock not found - this is expected for first build"
fi

# Build the Docker image
print_status "Building Docker image..."
print_status "This may take a few minutes on first build..."

# Show build progress
if $DOCKER_COMPOSE build --no-cache --progress=plain; then
    print_success "Docker image built successfully!"
else
    print_error "Docker build failed!"
    print_status "Common solutions:"
    echo "  1. Make sure Docker has enough memory allocated"
    echo "  2. Try: docker system prune -f"
    echo "  3. Run: bundle lock --add-platform x86_64-linux (locally)"
    echo "  4. Check Docker logs above for specific errors"
    exit 1
fi

# Start the services
print_status "Starting services..."
if $DOCKER_COMPOSE up -d; then
    print_success "Services started successfully!"
else
    print_error "Failed to start services!"
    exit 1
fi

# Show data persistence info
echo ""
print_status "💾 Data Persistence Enabled:"
echo "============================="
if [ -f "db/production.sqlite3" ]; then
    DB_SIZE=$(du -h db/production.sqlite3 2>/dev/null | cut -f1 || echo "Unknown")
    print_success "Database persisted in ./db/ (Size: $DB_SIZE)"
else
    print_success "Database will be created in ./db/ (persisted)"
fi
print_success "Logs persisted in ./log/"
print_success "Storage persisted in ./storage/"
print_success "Temp files persisted in ./tmp/"
echo "   • Your data survives container rebuilds"
echo "   • Run './backup-data.sh' to create backups"

# Wait a moment for services to start
print_status "Waiting for services to initialize..."
sleep 10

# Check service status
print_status "Checking service status..."
$DOCKER_COMPOSE ps

# Show logs for a few seconds
print_status "Recent application logs:"
echo "========================"
$DOCKER_COMPOSE logs --tail=20 web

echo ""
print_success "🎉 Deployment Complete!"
echo ""
echo "📱 Access your Todo Today app at:"
echo "   • http://bigbox:3000"
echo "   • http://$(hostname -I | awk '{print $1}'):3000"
echo ""
echo "🔧 Useful commands:"
echo "   • View logs: $DOCKER_COMPOSE logs -f web"
echo "   • Stop: $DOCKER_COMPOSE stop"
echo "   • Restart: $DOCKER_COMPOSE restart"
echo "   • Update: git pull && $DOCKER_COMPOSE build && $DOCKER_COMPOSE up -d"
echo ""

# Check if nginx is running (optional)
if $DOCKER_COMPOSE ps | grep -q nginx; then
    print_success "🌐 Nginx reverse proxy is running on port 8080"
    echo "   • Proxy access: http://bigbox:8080"
    echo "   • Static asset caching enabled"
    echo "   • Rate limiting configured"
else
    print_success "🚀 Rails app running directly on port 3000"
    echo "   • Direct Rails access (recommended for home server)"
fi

# Check for Google OAuth setup only if enabled
OAUTH_ENABLED=$(grep "ENABLE_GOOGLE_OAUTH=" .env | cut -d'=' -f2 2>/dev/null || echo "false")
if [ "$OAUTH_ENABLED" = "true" ]; then
    if ! grep -q "GOOGLE_CLIENT_ID" .env || grep -q "GOOGLE_CLIENT_ID=your_google_client_id_here" .env; then
        echo ""
        print_warning "🔐 Google OAuth is enabled but not configured:"
        echo "   1. Get credentials from Google Cloud Console"
        echo "   2. Add them to .env file:"
        echo "      GOOGLE_CLIENT_ID=your_client_id_here"
        echo "      GOOGLE_CLIENT_SECRET=your_client_secret_here"
        echo "   3. Add redirect URI: http://bigbox:3000/users/auth/google_oauth2/callback"
        echo "   4. Restart with: $DOCKER_COMPOSE restart"
    else
        print_success "🔐 Google OAuth is configured and enabled"
    fi
else
    echo ""
    print_success "🔐 Google OAuth is disabled (email/password login only)"
    echo "   To enable Google OAuth later:"
    echo "   1. Set ENABLE_GOOGLE_OAUTH=true in .env file"
    echo "   2. Add Google credentials to .env"
    echo "   3. Restart containers"
fi

echo ""
print_status "📁 Data Location Summary:"
echo "========================="
echo "• Database: $(pwd)/db/production.sqlite3"
echo "• Logs: $(pwd)/log/"
echo "• Storage: $(pwd)/storage/"
echo "• Backups: Run './backup-data.sh' anytime"
echo ""
print_success "Happy task tracking! 🚀"

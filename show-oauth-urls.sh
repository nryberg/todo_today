#!/bin/bash

echo "🔐 Google OAuth Configuration Helper"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header "Finding available network addresses..."

# Get server hostname
HOSTNAME=$(hostname)
print_success "Server hostname: $HOSTNAME"

# Get all IP addresses
echo ""
print_header "Available IP addresses:"
IPS=$(hostname -I 2>/dev/null || ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')

if [ -z "$IPS" ]; then
    # Fallback method for different systems
    IPS=$(ip addr show 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d'/' -f1)
fi

for ip in $IPS; do
    print_success "IP Address: $ip"
done

echo ""
print_header "🌐 Recommended Google OAuth Redirect URIs"
echo "=========================================="
echo ""
echo "Add ALL of these to your Google Cloud Console OAuth configuration:"
echo ""

# Standard localhost for development
echo "1. Development (localhost):"
echo "   http://localhost:3000/users/auth/google_oauth2/callback"
echo ""

# Hostname-based URLs
echo "2. Hostname-based:"
echo "   http://$HOSTNAME/users/auth/google_oauth2/callback"
echo "   http://$HOSTNAME.local/users/auth/google_oauth2/callback"
echo ""

# IP-based URLs
echo "3. IP-based (most reliable):"
for ip in $IPS; do
    echo "   http://$ip/users/auth/google_oauth2/callback"
done

echo ""
print_header "🔧 How to configure Google OAuth:"
echo "================================="
echo ""
echo "1. Go to Google Cloud Console:"
echo "   https://console.cloud.google.com/"
echo ""
echo "2. Navigate to: APIs & Services > Credentials"
echo ""
echo "3. Click on your OAuth 2.0 Client ID (or create one)"
echo ""
echo "4. In 'Authorized redirect URIs', add the URLs above"
echo ""
echo "5. Save the configuration"
echo ""
echo "6. Copy your Client ID and Client Secret"
echo ""

print_header "🔐 Add credentials to your .env file:"
echo "===================================="
echo ""
echo "Add these lines to your .env file:"
echo ""
echo "GOOGLE_CLIENT_ID=your_google_client_id_here"
echo "GOOGLE_CLIENT_SECRET=your_google_client_secret_here"
echo ""

print_header "🚀 Current service status:"
echo "=========================="

# Check if Docker containers are running
if command -v docker &> /dev/null; then
    if [ -f "docker-compose.yml" ]; then
        echo ""
        docker compose ps 2>/dev/null || docker-compose ps 2>/dev/null || echo "Docker compose not available"
    fi
fi

echo ""
print_header "📱 Test your OAuth setup by visiting:"
echo "===================================="
for ip in $IPS; do
    echo "   http://$ip"
done
echo "   http://$HOSTNAME.local (if on Mac network)"

echo ""
print_warning "Note: Use the IP address version for most reliable Google OAuth setup!"
print_success "After configuration, restart your containers: docker compose restart"

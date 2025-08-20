#!/bin/bash

# StoryGen Cloud Shell Run Script
# This script runs both frontend and backend in Google Cloud Shell

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
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

# Function to cleanup background processes
cleanup() {
    print_status "Stopping backend service..."
    if [[ ! -z "$BACKEND_PID" ]]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    print_success "Service stopped"
    exit 0
}

# Set up signal handling
trap cleanup SIGINT SIGTERM

# Check if .env file exists in parent directory and copy it to backend
if [[ ! -f .env ]]; then
    print_error ".env file not found in parent directory!"
    print_error "Please run setup-cloudshell.sh first"
    exit 1
fi

# Copy .env from parent directory to backend directory
print_status "Using .env file from parent directory"
cp .env backend/.env

# Check if API key is set
if grep -q "your_actual_google_api_key_here" backend/.env; then
    print_error "Please update your Google API key in .env file"
    print_error "Get your API key from: https://aistudio.google.com/"
    exit 1
fi

print_status "Starting StoryGen in Google Cloud Shell..."

# Check if frontend is built
if [[ ! -d "frontend/out" ]]; then
    print_error "Frontend not built! Please run setup-cloudshell.sh first"
    exit 1
fi

# Start backend (which serves the frontend)
print_status "Starting backend on port 8000 (serving frontend + API)..."
cd backend
export SSL_CERT_FILE=$(python -m certifi)
python main.py &
BACKEND_PID=$!
cd ..

# Wait a moment for backend to start
sleep 3

print_success "StoryGen is now running!"
echo ""
print_status "Access your application:"
if [[ ! -z "$WEB_HOST" ]]; then
    echo -e "${GREEN}   Application: https://8000-${WEB_HOST}.cloudshell.dev${NC}"
else
    echo -e "${GREEN}   Application: Click the Web Preview button and select port 8000${NC}"
fi
echo ""
print_status "Features available:"
echo -e "${GREEN}   • Frontend UI served at /${NC}"
echo -e "${GREEN}   • WebSocket API at /ws/{user_id}${NC}"
echo -e "${GREEN}   • Health check at /health${NC}"
echo ""
print_warning "Press Ctrl+C to stop the service"

# Keep script running and wait for signal
wait

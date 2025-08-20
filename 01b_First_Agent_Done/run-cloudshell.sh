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
    print_status "Stopping services..."
    if [[ ! -z "$BACKEND_PID" ]]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [[ ! -z "$FRONTEND_PID" ]]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    print_success "Services stopped"
    exit 0
}

# Set up signal handling
trap cleanup SIGINT SIGTERM

# Check if .env file exists with API key
if [[ ! -f backend/.env ]]; then
    print_error "backend/.env file not found!"
    print_error "Please run setup-cloudshell.sh first"
    exit 1
fi

# Check if API key is set
if grep -q "your_actual_google_api_key_here" backend/.env; then
    print_error "Please update your Google API key in backend/.env"
    print_error "Get your API key from: https://aistudio.google.com/"
    exit 1
fi

print_status "Starting StoryGen in Google Cloud Shell..."

# Start backend
print_status "Starting backend on port 8000..."
cd backend
export SSL_CERT_FILE=$(python -m certifi)
python main.py &
BACKEND_PID=$!
cd ..

# Wait a moment for backend to start
sleep 3

# Start frontend
print_status "Starting frontend on port 3000..."
cd frontend
npm run start &
FRONTEND_PID=$!
cd ..

# Wait a moment for frontend to start
sleep 5

print_success "StoryGen is now running!"
echo ""
print_status "Access your application:"
if [[ ! -z "$WEB_HOST" ]]; then
    echo -e "${GREEN}   Frontend: https://3000-${WEB_HOST}.cloudshell.dev${NC}"
    echo -e "${GREEN}   Backend:  https://8000-${WEB_HOST}.cloudshell.dev${NC}"
else
    echo -e "${GREEN}   Frontend: Click the Web Preview button and select port 3000${NC}"
    echo -e "${GREEN}   Backend:  Click the Web Preview button and select port 8000${NC}"
fi
echo ""
print_warning "Press Ctrl+C to stop all services"

# Keep script running and wait for signal
wait

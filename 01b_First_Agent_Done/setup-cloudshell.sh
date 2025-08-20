#!/bin/bash

# StoryGen Cloud Shell Setup Script
# This script sets up both frontend and backend for running in Google Cloud Shell

set -e

echo "🚀 Setting up StoryGen for Google Cloud Shell..."

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

# Check if we're in Cloud Shell
if [[ -z "$CLOUD_SHELL" ]]; then
    print_warning "This script is optimized for Google Cloud Shell"
    print_warning "It may work in other environments but is not guaranteed"
fi

# Setup backend
print_status "Setting up backend..."
cd backend

# Install Python dependencies
print_status "Installing Python dependencies..."
pip install -r requirements.txt

# Set SSL certificate for ADK
print_status "Setting SSL certificate..."
export SSL_CERT_FILE=$(python -m certifi)
echo "export SSL_CERT_FILE=$(python -m certifi)" >> ~/.bashrc

# Check for environment file in parent directory
if [[ -f ../.env ]]; then
    print_success "Found .env file in parent directory"
    print_status "Copying .env file to backend directory..."
    cp ../.env .env
else
    print_warning "No .env file found in parent directory. Creating template..."
    cat > .env << EOF
# Google AI API Configuration
GOOGLE_GENAI_USE_VERTEXAI=FALSE
GOOGLE_API_KEY=your_actual_google_api_key_here

# Optional: Google Cloud Project for image generation
# GOOGLE_CLOUD_PROJECT_ID=your-project-id
EOF
    print_warning "Please edit backend/.env and add your Google API key"
    print_warning "Get your API key from: https://aistudio.google.com/"
fi

cd ..

# Setup frontend
print_status "Setting up frontend..."
cd frontend

# Install Node.js dependencies
print_status "Installing Node.js dependencies..."
npm install

# Build frontend for static export
print_status "Building frontend for static export..."
npm run build

cd ..

print_success "Setup complete!"
echo ""
print_status "To start the application:"
echo -e "${YELLOW}1. Make sure your Google API key is in backend/.env${NC}"
echo -e "${YELLOW}2. Run: ./run-cloudshell.sh${NC}"
echo ""
print_status "The application will be available at:"
echo -e "${GREEN}   Single URL: https://8000-\$WEB_HOST.cloudshell.dev${NC}"
echo -e "${GREEN}   (Frontend + Backend served from same origin)${NC}"

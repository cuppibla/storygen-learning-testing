# StoryGen - Google Cloud Shell Setup

This guide explains how to run StoryGen (both frontend and backend) in Google Cloud Shell with Web Preview URLs.

## Quick Start

1. **Setup** (run once):
   ```bash
   ./setup-cloudshell.sh
   ```

2. **Configure API Key**:
   - Edit `backend/.env` and replace `your_actual_google_api_key_here` with your actual Google AI Studio API key
   - Get your API key from: https://aistudio.google.com/

3. **Run the application**:
   ```bash
   ./run-cloudshell.sh
   ```

4. **Access the application**:
   - Click the **Web Preview** button in Cloud Shell
   - Select **Preview on port 3000** for the frontend
   - The frontend will automatically connect to the backend on port 8000

## What's Fixed for Cloud Shell

### CORS Configuration
The backend now allows connections from Cloud Shell Web Preview URLs:
```python
allow_origin_regex=r"https?://.*(localhost|cloudshell\.dev)(:\d+)?|https?://.*\.run\.app"
```

### Dynamic URL Detection
The frontend automatically detects if it's running in Cloud Shell and adjusts the WebSocket URL:
```javascript
if (hostname.includes('cloudshell.dev')) {
  // Cloud Shell environment - use the same hostname but port 8000
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  wsBaseUrl = `${protocol}//${hostname.replace(/3000/, '8000')}`;
}
```

### Network Configuration
- Backend listens on `0.0.0.0:8000` (accessible from outside the container)
- Frontend runs on port 3000
- WebSocket connections automatically use the correct protocol (WSS for HTTPS)

## Architecture

```
Cloud Shell Environment:
┌─────────────────────────────────────────┐
│  https://3000-{hash}.cloudshell.dev     │ ← Frontend
│  ↓ WebSocket Connection                 │
│  wss://8000-{hash}.cloudshell.dev/ws/   │ ← Backend
└─────────────────────────────────────────┘
```

## Manual Setup (if scripts don't work)

### Backend Setup
```bash
cd backend
pip install -r requirements.txt
export SSL_CERT_FILE=$(python -m certifi)

# Create .env file:
echo "GOOGLE_GENAI_USE_VERTEXAI=FALSE" > .env
echo "GOOGLE_API_KEY=your_actual_api_key" >> .env

# Run backend
python main.py
```

### Frontend Setup
```bash
cd frontend
npm install
npm run start
```

## Troubleshooting

### CORS Errors
If you see CORS errors in the browser console:
1. Check that the backend is running on port 8000
2. Verify the CORS configuration in `backend/main.py`
3. Make sure you're accessing the frontend via Web Preview (not direct URL)

### WebSocket Connection Failed
If the WebSocket connection fails:
1. Check browser console for exact error message
2. Verify both services are running (`ps aux | grep -E "(node|python)"`)
3. Try refreshing the frontend page
4. Check that ports 3000 and 8000 are both available in Web Preview

### API Key Issues
If you get API key errors:
1. Verify your API key is correct in `backend/.env`
2. Make sure the key is from Google AI Studio (not Google Cloud Console)
3. Check that the key has appropriate permissions

### SSL Certificate Issues
If you get SSL/certificate errors:
```bash
export SSL_CERT_FILE=$(python -m certifi)
echo "export SSL_CERT_FILE=$(python -m certifi)" >> ~/.bashrc
```

## Development Tips

- Use Web Preview for both services to avoid CORS issues
- The frontend automatically detects Cloud Shell and adjusts URLs
- Backend logs are visible in the terminal where you ran the script
- Press Ctrl+C in the terminal to stop both services

## URL Examples

When running in Cloud Shell, your URLs will look like:
- Frontend: `https://3000-cs-123456789-default.cloudshell.dev`
- Backend: `https://8000-cs-123456789-default.cloudshell.dev`
- WebSocket: `wss://8000-cs-123456789-default.cloudshell.dev/ws/{user_id}`

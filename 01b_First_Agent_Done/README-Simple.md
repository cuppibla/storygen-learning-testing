# StoryGen - Simple Cloud Shell Setup

No scripts needed! Just run these commands directly:

## 1. Setup (run once)

```bash
# Install backend dependencies
cd backend
pip install -r requirements.txt
export SSL_CERT_FILE=$(python -m certifi)

# Copy .env from parent directory (where your API key is)
cp ../.env .env

# Build frontend for static serving
cd ../frontend
npm install
npm run build

cd ..
```

## 2. Run the application

```bash
# Start the backend (serves frontend + API)
cd backend
export SSL_CERT_FILE=$(python -m certifi)
python main.py
```

## 3. Access the app

- Click **Web Preview** → **Preview on port 8000**
- Everything (frontend + backend) served from same URL
- No CORS issues since same origin

## How it works

1. **Frontend** builds to `frontend/out/` (static files)
2. **Backend** serves frontend at `/` and API at `/ws/`, `/health`, etc.
3. **WebSocket** connects to same host automatically
4. **Single port 8000** - no need for separate frontend server

## The key changes

### Backend (`main.py`)
```python
# Serve frontend static files
STATIC_FILES_DIR = os.environ.get("STATIC_FILES_DIR", "../frontend/out")
app.mount("/", StaticFiles(directory=STATIC_FILES_DIR, html=True), name="static")
```

### Frontend (`next.config.mjs`)
```javascript
{
  output: 'export',    // Static export
  distDir: 'out',      // Output directory
}
```

### WebSocket connection (`page.tsx`)
```javascript
// Uses same origin - no localhost hardcoding
const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
const host = window.location.host;
wsBaseUrl = `${protocol}//${host}`;
```

This fixes the Cloud Shell issue because:
- ✅ No hardcoded `localhost:8000` 
- ✅ WebSocket uses same origin as frontend
- ✅ CORS allows `cloudshell.dev` domains
- ✅ Single service, single port

# AWS Static Site: Local Stop

Stop the local development server.

## Prerequisites

- Local server running (started with `/yaccp-aws-static-site:yaccp-aws-static-site-local-start`)

---

## Interactive Flow

### Step 1: Check for running server

```bash
# Check if PID file exists
if [ ! -f ".claude/yaccp/aws-static-site/local.pid" ]; then
  echo "No local server is currently running."
  exit 0
fi

PID=$(cat .claude/yaccp/aws-static-site/local.pid)
```

### Step 2: Check if process is still running

```bash
if ! ps -p $PID > /dev/null 2>&1; then
  echo "Server process no longer running (stale PID file)."
  rm -f .claude/yaccp/aws-static-site/local.pid
  rm -f .claude/yaccp/aws-static-site/local.url
  exit 0
fi
```

### Step 3: Stop the server

```bash
# Get server URL for display
URL=$(cat .claude/yaccp/aws-static-site/local.url 2>/dev/null || echo "unknown")

# Kill the process
kill $PID 2>/dev/null

# Wait for graceful shutdown
sleep 2

# Force kill if still running
if ps -p $PID > /dev/null 2>&1; then
  kill -9 $PID 2>/dev/null
fi

# Clean up PID and URL files
rm -f .claude/yaccp/aws-static-site/local.pid
rm -f .claude/yaccp/aws-static-site/local.url
```

### Step 4: Display success

```
Local Development Server Stopped
================================

Server at {URL} has been stopped.
Process {PID} terminated.

Commands:
- Start server:  /yaccp-aws-static-site:yaccp-aws-static-site-local-start
- Deploy to AWS: /yaccp-aws-static-site:yaccp-aws-static-site-deploy
```

---

## Error Handling

### No server running
```
No local server is currently running.

Start one with: /yaccp-aws-static-site:yaccp-aws-static-site-local-start
```

### Permission denied
```
Could not stop server (permission denied).

Try manually:
  kill {PID}

Or force kill:
  kill -9 {PID}
```

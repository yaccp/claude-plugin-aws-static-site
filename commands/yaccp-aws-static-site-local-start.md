# AWS Static Site: Local Start

Start the local development server for your static site.

## Prerequisites

- Project initialized with `/yaccp-aws-static-site:yaccp-aws-static-site-init`
- Dependencies installed (npm install if applicable)

---

## Interactive Flow

### Step 1: Check configuration

```bash
# Check if project is initialized
if [ ! -f ".claude/yaccp/aws-static-site/config.json" ]; then
  echo "Project not initialized. Run /yaccp-aws-static-site:yaccp-aws-static-site-init first."
  exit 1
fi
```

Read the configuration to get the generator type:
```bash
cat .claude/yaccp/aws-static-site/config.json
```

### Step 2: Check for existing server

```bash
# Check if a dev server is already running
if [ -f ".claude/yaccp/aws-static-site/local.pid" ]; then
  PID=$(cat .claude/yaccp/aws-static-site/local.pid)
  if ps -p $PID > /dev/null 2>&1; then
    echo "Local server already running (PID: $PID)"
    echo "Use /yaccp-aws-static-site:yaccp-aws-static-site-local-status to check"
    exit 0
  fi
fi
```

### Step 3: Start the development server

Based on the `generator` field in config.json:

**Hugo:**
```bash
hugo server --bind 0.0.0.0 --port 1313 --disableFastRender &
echo $! > .claude/yaccp/aws-static-site/local.pid
echo "http://localhost:1313" > .claude/yaccp/aws-static-site/local.url
```

**Astro:**
```bash
npm run dev -- --port 4321 &
echo $! > .claude/yaccp/aws-static-site/local.pid
echo "http://localhost:4321" > .claude/yaccp/aws-static-site/local.url
```

**11ty (Eleventy):**
```bash
npx @11ty/eleventy --serve --port 8080 &
echo $! > .claude/yaccp/aws-static-site/local.pid
echo "http://localhost:8080" > .claude/yaccp/aws-static-site/local.url
```

**Next.js:**
```bash
npm run dev -- --port 3000 &
echo $! > .claude/yaccp/aws-static-site/local.pid
echo "http://localhost:3000" > .claude/yaccp/aws-static-site/local.url
```

**Plain HTML:**
```bash
# Use Python's built-in HTTP server
python3 -m http.server 8000 &
echo $! > .claude/yaccp/aws-static-site/local.pid
echo "http://localhost:8000" > .claude/yaccp/aws-static-site/local.url
```

### Step 4: Wait for server startup

```bash
# Wait a few seconds for server to start
sleep 3

# Check if process is still running
PID=$(cat .claude/yaccp/aws-static-site/local.pid)
if ! ps -p $PID > /dev/null 2>&1; then
  echo "Server failed to start"
  rm -f .claude/yaccp/aws-static-site/local.pid
  rm -f .claude/yaccp/aws-static-site/local.url
  exit 1
fi
```

### Step 5: Display success

```
Local Development Server Started!
=================================

Server URL: http://localhost:1313
Process ID: 12345

The server is running with live reload enabled.
Edit your files and see changes instantly.

Commands:
- Check status:  /yaccp-aws-static-site:yaccp-aws-static-site-local-status
- Stop server:   /yaccp-aws-static-site:yaccp-aws-static-site-local-stop
- Deploy to AWS: /yaccp-aws-static-site:yaccp-aws-static-site-deploy
```

---

## Port Configuration

Use AskUserQuestion if port is already in use:
"Port {port} is already in use. What would you like to do?"
- "Use alternative port" - Try next available port
- "Kill existing process" - Stop what's using the port
- "Cancel" - Don't start server

## Error Handling

### Dependencies not installed
```
Dependencies not installed. Run:

  npm install

Then try again.
```

### Port in use
```
Port 1313 is already in use.

Either stop the existing process or run with a different port.
```

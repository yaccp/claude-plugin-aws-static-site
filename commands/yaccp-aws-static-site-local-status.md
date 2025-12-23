# AWS Static Site: Local Status

Check the status of the local development server.

## Prerequisites

- Project initialized with `/yaccp-aws-static-site:yaccp-aws-static-site-init`

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

### Step 2: Read configuration

```bash
cat .claude/yaccp/aws-static-site/config.json
```

Extract generator type and build settings.

### Step 3: Check server status

```bash
# Check if PID file exists
if [ ! -f ".claude/yaccp/aws-static-site/local.pid" ]; then
  SERVER_STATUS="not running"
  SERVER_PID=""
  SERVER_URL=""
else
  SERVER_PID=$(cat .claude/yaccp/aws-static-site/local.pid)
  SERVER_URL=$(cat .claude/yaccp/aws-static-site/local.url 2>/dev/null || echo "unknown")

  if ps -p $SERVER_PID > /dev/null 2>&1; then
    SERVER_STATUS="running"
  else
    SERVER_STATUS="stopped (stale PID)"
    # Clean up stale files
    rm -f .claude/yaccp/aws-static-site/local.pid
    rm -f .claude/yaccp/aws-static-site/local.url
  fi
fi
```

### Step 4: Check port availability

Based on the generator, check if the default port is available:

```bash
# Hugo default
lsof -i :1313 2>/dev/null

# Astro default
lsof -i :4321 2>/dev/null

# 11ty default
lsof -i :8080 2>/dev/null

# Next.js default
lsof -i :3000 2>/dev/null

# Plain HTML default
lsof -i :8000 2>/dev/null
```

### Step 5: Display status

**If server is running:**
```
Local Development Server Status
===============================

Status:    RUNNING
URL:       http://localhost:1313
PID:       12345
Generator: Hugo

The server is running with live reload enabled.

Commands:
- Stop server:   /yaccp-aws-static-site:yaccp-aws-static-site-local-stop
- Deploy to AWS: /yaccp-aws-static-site:yaccp-aws-static-site-deploy
```

**If server is not running:**
```
Local Development Server Status
===============================

Status:    NOT RUNNING
Generator: Hugo

Start the development server:
  /yaccp-aws-static-site:yaccp-aws-static-site-local-start

Or build and deploy:
  /yaccp-aws-static-site:yaccp-aws-static-site-deploy
```

**If project not initialized:**
```
Local Development Server Status
===============================

Status: NOT CONFIGURED

Initialize your project first:
  /yaccp-aws-static-site:yaccp-aws-static-site-init
```

---

## Port Information

| Generator | Default Port | Dev Command |
|-----------|--------------|-------------|
| Hugo      | 1313         | hugo server |
| Astro     | 4321         | npm run dev |
| 11ty      | 8080         | npx @11ty/eleventy --serve |
| Next.js   | 3000         | npm run dev |
| Plain HTML| 8000         | python3 -m http.server |

## Additional Diagnostics

If requested, show additional information:

```bash
# Check what's using the port
lsof -i :{port} | head -5

# Check system resources
ps aux | grep -E "(hugo|node|python)" | grep -v grep
```

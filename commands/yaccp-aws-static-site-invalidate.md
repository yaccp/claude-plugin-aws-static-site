# AWS Static Site: Invalidate Cache

Invalidate CloudFront cache to serve fresh content.

---

## Interactive Flow

### Step 1: Load configuration

```bash
CONFIG_FILE=".claude/yaccp/aws-static-site/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Project not initialized. Run /yaccp-aws-static-site:init first."
  exit 1
fi

ENV=$(jq -r '.currentEnvironment' "$CONFIG_FILE")
PROFILE=$(jq -r ".environments.$ENV.awsProfile" "$CONFIG_FILE")
SITE_NAME=$(jq -r ".environments.$ENV.siteName" "$CONFIG_FILE")
```

### Step 2: Find CloudFront distribution

```bash
DIST_ID=$(aws cloudfront list-distributions \
  --profile "$PROFILE" \
  --query "DistributionList.Items[?Comment=='${SITE_NAME}'].Id" \
  --output text)

if [ -z "$DIST_ID" ]; then
  echo "Error: No CloudFront distribution found for '$SITE_NAME'"
  exit 1
fi
```

### Step 3: Select invalidation scope

Use AskUserQuestion:
"What do you want to invalidate?"
- "Everything (/*)" (Recommended) - Invalidate all cached objects
- "HTML files only (/*.html)" - Just HTML pages
- "Specific path" - Enter a custom path pattern

If "Specific path" selected:
"Enter path pattern (e.g., /blog/*, /images/logo.png):"

### Step 4: Check current invalidations

```bash
# List recent invalidations
aws cloudfront list-invalidations \
  --distribution-id "$DIST_ID" \
  --profile "$PROFILE" \
  --query 'InvalidationList.Items[0:5]'
```

Display:
```
Recent Invalidations
--------------------
ID              Status      Created               Paths
INV123456789    Completed   2024-12-21T10:30:00Z  /*
INV987654321    Completed   2024-12-20T15:45:00Z  /blog/*
```

### Step 5: Create invalidation

```bash
INVALIDATION_PATH="${PATH:-/*}"

echo "Creating invalidation for: $INVALIDATION_PATH"

INVALIDATION=$(aws cloudfront create-invalidation \
  --distribution-id "$DIST_ID" \
  --paths "$INVALIDATION_PATH" \
  --profile "$PROFILE" \
  --output json)

INV_ID=$(echo "$INVALIDATION" | jq -r '.Invalidation.Id')
INV_STATUS=$(echo "$INVALIDATION" | jq -r '.Invalidation.Status')
```

### Step 6: Wait for completion (optional)

Use AskUserQuestion:
"Wait for invalidation to complete?"
- "Yes" - Wait and show progress (typically 1-5 minutes)
- "No" - Return immediately

If "Yes":
```bash
echo "Waiting for invalidation to complete..."

while [ "$INV_STATUS" = "InProgress" ]; do
  sleep 10
  INV_STATUS=$(aws cloudfront get-invalidation \
    --distribution-id "$DIST_ID" \
    --id "$INV_ID" \
    --profile "$PROFILE" \
    --query 'Invalidation.Status' \
    --output text)
  echo "Status: $INV_STATUS"
done
```

### Step 7: Display result

```
Cache Invalidation
==================

Distribution:    E1234567890ABC
Invalidation ID: INV123456789
Paths:           /*
Status:          Completed

The CloudFront cache has been invalidated.
Fresh content will be served on the next request.

Note: First 1,000 invalidations/month are free.
Additional invalidations: $0.005 per path.
```

---

## Usage Notes

### Invalidation Pricing
- First 1,000 path invalidations per month: Free
- Additional: $0.005 per path
- Wildcards count as one path (e.g., `/blog/*` = 1 path)

### Best Practices
- Use `/*` sparingly (invalidates everything)
- Prefer versioned filenames for assets (e.g., `style.v2.css`)
- Group related invalidations together

### Common Patterns
```
/*              # Everything
/index.html     # Single file
/blog/*         # All blog posts
/images/*.png   # All PNG images
```

# AWS Static Site: Deploy

Deploy static site to AWS S3 + CloudFront.

## Prerequisites

- Project initialized with `/yaccp-aws-static-site:init`
- AWS credentials configured
- Site built (output directory exists)

---

## Interactive Flow

### Step 1: Load configuration

```bash
CONFIG_FILE=".claude/yaccp/aws-static-site/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Project not initialized. Run /yaccp-aws-static-site:init first."
  exit 1
fi
```

### Step 2: Validate environment

```bash
# Get current environment from config
ENV=$(jq -r '.currentEnvironment' "$CONFIG_FILE")
PROFILE=$(jq -r ".environments.$ENV.awsProfile" "$CONFIG_FILE")
REGION=$(jq -r ".environments.$ENV.awsRegion" "$CONFIG_FILE")

# Validate credentials
aws sts get-caller-identity --profile "$PROFILE" --region "$REGION"
```

### Step 3: Build site

```bash
BUILD_CMD=$(jq -r '.buildCommand' "$CONFIG_FILE")
OUTPUT_DIR=$(jq -r '.outputDirectory' "$CONFIG_FILE")

# Run build command
eval "$BUILD_CMD"

# Verify output exists
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Error: Output directory '$OUTPUT_DIR' not found after build"
  exit 1
fi
```

### Step 4: Display deployment summary

Use AskUserQuestion:
```
Deployment Configuration
========================
Environment:     dev
AWS Profile:     dev-profile
AWS Region:      eu-west-1
AWS Account:     111111111111

Site Configuration:
Site Name:       my-blog-dev
S3 Bucket:       my-blog-dev-static-site
CloudFront:      d1234567890abc.cloudfront.net
Custom Domain:   dev.example.com

Files to deploy: 45 files (2.3 MB)

Proceed?
● Yes, deploy now
○ Show diff first
○ Switch environment
```

### Step 5: Create/Update S3 bucket

```bash
BUCKET_NAME="${SITE_NAME}-static-site"

# Check if bucket exists
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  # Create bucket
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"

  # Block public access (CloudFront will use OAC)
  aws s3api put-public-access-block \
    --bucket "$BUCKET_NAME" \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
fi
```

### Step 6: Sync files to S3

```bash
aws s3 sync "$OUTPUT_DIR" "s3://$BUCKET_NAME" \
  --delete \
  --cache-control "max-age=31536000" \
  --exclude "*.html" \
  --profile "$PROFILE" \
  --region "$REGION"

# HTML files with shorter cache
aws s3 sync "$OUTPUT_DIR" "s3://$BUCKET_NAME" \
  --cache-control "max-age=3600" \
  --include "*.html" \
  --profile "$PROFILE" \
  --region "$REGION"
```

### Step 7: Create/Update CloudFront distribution

If distribution doesn't exist:
```bash
# Create Origin Access Control
aws cloudfront create-origin-access-control \
  --origin-access-control-config \
  "Name=${SITE_NAME}-oac,SigningProtocol=sigv4,SigningBehavior=always,OriginAccessControlOriginType=s3"

# Create distribution with S3 origin
aws cloudfront create-distribution \
  --distribution-config file://cloudfront-config.json
```

### Step 8: Request SSL certificate (if custom domain)

```bash
if [ -n "$DOMAIN_NAME" ]; then
  # Request certificate in us-east-1 (required for CloudFront)
  CERT_ARN=$(aws acm request-certificate \
    --domain-name "$DOMAIN_NAME" \
    --validation-method DNS \
    --region us-east-1 \
    --query 'CertificateArn' \
    --output text)

  # Create Route53 validation record
  # Wait for validation...
fi
```

### Step 9: Create Route53 records (if custom domain)

```bash
if [ -n "$DOMAIN_NAME" ] && [ -n "$HOSTED_ZONE_ID" ]; then
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch file://route53-alias.json
fi
```

### Step 10: Invalidate CloudFront cache

```bash
aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*"
```

### Step 11: Display success

```
Deployment Complete!
====================

Site URL:        https://dev.example.com
CloudFront URL:  https://d1234567890abc.cloudfront.net
S3 Bucket:       my-blog-dev-static-site

Files deployed:  45 files
Total size:      2.3 MB
Deploy time:     32 seconds

Cache invalidation in progress (typically 5-10 minutes).

Next steps:
- View logs:     /yaccp-aws-static-site:status
- Invalidate:    /yaccp-aws-static-site:invalidate
```

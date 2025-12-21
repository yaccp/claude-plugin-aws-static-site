# AWS Static Site: Doctor

Diagnose configuration issues and validate prerequisites.

---

## Interactive Flow

### Step 1: Check prerequisites

```bash
echo "Checking prerequisites..."

# AWS CLI
if command -v aws &> /dev/null; then
  AWS_VERSION=$(aws --version | cut -d/ -f2 | cut -d' ' -f1)
  echo "✓ AWS CLI: v$AWS_VERSION"
else
  echo "✗ AWS CLI: Not installed"
  echo "  Install: https://aws.amazon.com/cli/"
fi

# Node.js
if command -v node &> /dev/null; then
  NODE_VERSION=$(node --version)
  echo "✓ Node.js: $NODE_VERSION"
else
  echo "✗ Node.js: Not installed"
  echo "  Install: https://nodejs.org/"
fi

# Static site generator
for cmd in hugo astro npx; do
  if command -v $cmd &> /dev/null; then
    echo "✓ $cmd: Available"
  fi
done
```

### Step 2: Check AWS configuration

```bash
CONFIG_FILE=".claude/yaccp/aws-static-site/config.json"

if [ -f "$CONFIG_FILE" ]; then
  ENV=$(jq -r '.currentEnvironment' "$CONFIG_FILE")
  PROFILE=$(jq -r ".environments.$ENV.awsProfile" "$CONFIG_FILE")
  REGION=$(jq -r ".environments.$ENV.awsRegion" "$CONFIG_FILE")

  echo ""
  echo "AWS Configuration"
  echo "-----------------"

  # Check profile exists
  if aws configure list --profile "$PROFILE" &> /dev/null; then
    echo "✓ AWS Profile: $PROFILE"
  else
    echo "✗ AWS Profile: $PROFILE (not found)"
    echo "  Run: aws configure --profile $PROFILE"
  fi

  # Check credentials
  if aws sts get-caller-identity --profile "$PROFILE" &> /dev/null; then
    ACCOUNT=$(aws sts get-caller-identity --profile "$PROFILE" --query 'Account' --output text)
    echo "✓ AWS Credentials: Valid (Account: $ACCOUNT)"
  else
    echo "✗ AWS Credentials: Invalid or expired"
    echo "  Run: aws sso login --profile $PROFILE"
  fi

  # Check region
  echo "✓ AWS Region: $REGION"
else
  echo ""
  echo "✗ Configuration: Not found"
  echo "  Run: /yaccp-aws-static-site:init"
fi
```

### Step 3: Check project configuration

```bash
if [ -f "$CONFIG_FILE" ]; then
  echo ""
  echo "Project Configuration"
  echo "---------------------"

  GENERATOR=$(jq -r '.generator' "$CONFIG_FILE")
  BUILD_CMD=$(jq -r '.buildCommand' "$CONFIG_FILE")
  OUTPUT_DIR=$(jq -r '.outputDirectory' "$CONFIG_FILE")

  echo "Generator:        $GENERATOR"
  echo "Build Command:    $BUILD_CMD"
  echo "Output Directory: $OUTPUT_DIR"

  # Check if output directory exists
  if [ -d "$OUTPUT_DIR" ]; then
    FILE_COUNT=$(find "$OUTPUT_DIR" -type f | wc -l)
    echo "✓ Output Directory: Exists ($FILE_COUNT files)"
  else
    echo "⚠ Output Directory: Not found (run build first)"
  fi
fi
```

### Step 4: Check AWS resources

```bash
if [ -f "$CONFIG_FILE" ]; then
  SITE_NAME=$(jq -r ".environments.$ENV.siteName" "$CONFIG_FILE")
  BUCKET_NAME="${SITE_NAME}-static-site"

  echo ""
  echo "AWS Resources"
  echo "-------------"

  # Check S3 bucket
  if aws s3api head-bucket --bucket "$BUCKET_NAME" --profile "$PROFILE" 2>/dev/null; then
    echo "✓ S3 Bucket: $BUCKET_NAME"
  else
    echo "○ S3 Bucket: Not created yet"
  fi

  # Check CloudFront
  DIST=$(aws cloudfront list-distributions \
    --profile "$PROFILE" \
    --query "DistributionList.Items[?Comment=='${SITE_NAME}'].Id" \
    --output text 2>/dev/null)

  if [ -n "$DIST" ]; then
    echo "✓ CloudFront: $DIST"
  else
    echo "○ CloudFront: Not created yet"
  fi

  # Check ACM certificate
  DOMAIN_NAME=$(jq -r ".environments.$ENV.domainName" "$CONFIG_FILE")
  if [ -n "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "null" ]; then
    CERT=$(aws acm list-certificates \
      --profile "$PROFILE" \
      --region us-east-1 \
      --query "CertificateSummaryList[?DomainName=='$DOMAIN_NAME'].CertificateArn" \
      --output text 2>/dev/null)

    if [ -n "$CERT" ]; then
      STATUS=$(aws acm describe-certificate \
        --certificate-arn "$CERT" \
        --region us-east-1 \
        --query 'Certificate.Status' \
        --output text)
      echo "✓ ACM Certificate: $STATUS"
    else
      echo "○ ACM Certificate: Not requested yet"
    fi
  fi
fi
```

### Step 5: Display summary

```
Static Site Doctor Report
=========================

Prerequisites
-------------
✓ AWS CLI:       v2.15.0
✓ Node.js:       v20.10.0
✓ Hugo:          v0.121.0

AWS Configuration
-----------------
✓ AWS Profile:   dev-profile
✓ AWS Region:    eu-west-1
✓ Credentials:   Valid (Account: 111111111111)

Project Configuration
---------------------
✓ Generator:     hugo
✓ Build Command: hugo --minify
✓ Output Dir:    public/ (45 files)

AWS Resources
-------------
✓ S3 Bucket:     my-blog-dev-static-site
✓ CloudFront:    E1234567890ABC
✓ ACM Cert:      ISSUED
✓ Route53:       dev.example.com → CloudFront

Status: All OK
```

---

## Common Issues

### Issue: AWS credentials expired
```
✗ AWS Credentials: Invalid or expired

Solution:
1. For SSO: aws sso login --profile dev-profile
2. For IAM: Check ~/.aws/credentials
```

### Issue: Certificate pending validation
```
⚠ ACM Certificate: PENDING_VALIDATION

Solution:
Add DNS record to Route53:
Name:  _abc123.dev.example.com
Type:  CNAME
Value: _def456.acm-validations.aws

Or run: /yaccp-aws-static-site:deploy to auto-create
```

### Issue: Build output missing
```
⚠ Output Directory: Not found

Solution:
Run your build command:
  hugo --minify

Then try deploy again.
```

# AWS Static Site: Status

Check infrastructure status and health for deployed static site.

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
REGION=$(jq -r ".environments.$ENV.awsRegion" "$CONFIG_FILE")
SITE_NAME=$(jq -r ".environments.$ENV.siteName" "$CONFIG_FILE")
```

### Step 2: Check S3 bucket

```bash
BUCKET_NAME="${SITE_NAME}-static-site"

# Get bucket info
aws s3api head-bucket --bucket "$BUCKET_NAME" --profile "$PROFILE"

# Get object count and size
aws s3 ls "s3://$BUCKET_NAME" --recursive --summarize --profile "$PROFILE" | tail -2
```

### Step 3: Check CloudFront distribution

```bash
# Find distribution by S3 origin
DISTRIBUTION=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?Origins.Items[?DomainName=='${BUCKET_NAME}.s3.${REGION}.amazonaws.com']]" \
  --output json)

# Get distribution status
DIST_ID=$(echo "$DISTRIBUTION" | jq -r '.[0].Id')
DIST_STATUS=$(echo "$DISTRIBUTION" | jq -r '.[0].Status')
DIST_DOMAIN=$(echo "$DISTRIBUTION" | jq -r '.[0].DomainName')
```

### Step 4: Check SSL certificate (if custom domain)

```bash
if [ -n "$DOMAIN_NAME" ]; then
  # Get certificate status
  aws acm describe-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --query 'Certificate.{Status:Status,NotAfter:NotAfter}'
fi
```

### Step 5: Check Route53 records

```bash
if [ -n "$HOSTED_ZONE_ID" ]; then
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Name=='${DOMAIN_NAME}.']"
fi
```

### Step 6: Test site availability

```bash
# Test CloudFront URL
curl -s -o /dev/null -w "%{http_code}" "https://$DIST_DOMAIN"

# Test custom domain (if configured)
if [ -n "$DOMAIN_NAME" ]; then
  curl -s -o /dev/null -w "%{http_code}" "https://$DOMAIN_NAME"
fi
```

### Step 7: Display status report

```
Static Site Status Report
=========================
Environment: dev

S3 Bucket
---------
Bucket Name:    my-blog-dev-static-site
Status:         Active
Objects:        45 files
Total Size:     2.3 MB
Last Modified:  2024-12-21T10:30:00Z

CloudFront Distribution
-----------------------
Distribution ID: E1234567890ABC
Status:          Deployed
Domain:          d1234567890abc.cloudfront.net
Price Class:     PriceClass_100
HTTP/2:          Enabled
IPv6:            Enabled

SSL Certificate
---------------
Domain:          dev.example.com
Status:          ISSUED
Expires:         2025-12-21
Type:            Amazon Issued

DNS (Route53)
-------------
Record:          dev.example.com
Type:            A (Alias)
Target:          d1234567890abc.cloudfront.net
TTL:             300

Health Check
------------
CloudFront URL:  200 OK (45ms)
Custom Domain:   200 OK (52ms)

Cache Status
------------
Last Invalidation: 2024-12-21T10:35:00Z
Status:            Completed
```

---

## Error States

### S3 Bucket Not Found
```
S3 Bucket
---------
Status: NOT FOUND

The S3 bucket 'my-blog-dev-static-site' does not exist.
Run /yaccp-aws-static-site:deploy to create it.
```

### CloudFront Not Deployed
```
CloudFront Distribution
-----------------------
Status: NOT FOUND

No CloudFront distribution found for this site.
Run /yaccp-aws-static-site:deploy to create it.
```

### Certificate Pending Validation
```
SSL Certificate
---------------
Domain:   dev.example.com
Status:   PENDING_VALIDATION

Action Required:
Add the following DNS record to validate the certificate:

Name:  _abc123.dev.example.com
Type:  CNAME
Value: _def456.acm-validations.aws
```

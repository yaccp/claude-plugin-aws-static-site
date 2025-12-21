# AWS Static Site: Destroy

Destroy all AWS infrastructure for the static site.

---

## Interactive Flow

### Step 1: Load configuration

```bash
CONFIG_FILE=".claude/yaccp/aws-static-site/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: No configuration found. Nothing to destroy."
  exit 1
fi

ENV=$(jq -r '.currentEnvironment' "$CONFIG_FILE")
PROFILE=$(jq -r ".environments.$ENV.awsProfile" "$CONFIG_FILE")
REGION=$(jq -r ".environments.$ENV.awsRegion" "$CONFIG_FILE")
SITE_NAME=$(jq -r ".environments.$ENV.siteName" "$CONFIG_FILE")
DOMAIN_NAME=$(jq -r ".environments.$ENV.domainName" "$CONFIG_FILE")
```

### Step 2: Inventory resources

```bash
BUCKET_NAME="${SITE_NAME}-static-site"

# Find CloudFront distribution
DIST_ID=$(aws cloudfront list-distributions \
  --profile "$PROFILE" \
  --query "DistributionList.Items[?Comment=='${SITE_NAME}'].Id" \
  --output text)

# Find ACM certificate
if [ -n "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "null" ]; then
  CERT_ARN=$(aws acm list-certificates \
    --profile "$PROFILE" \
    --region us-east-1 \
    --query "CertificateSummaryList[?DomainName=='$DOMAIN_NAME'].CertificateArn" \
    --output text)
fi
```

### Step 3: Display destruction warning

```
⚠️  DESTRUCTION WARNING
======================

This will PERMANENTLY DELETE the following resources:

Environment: dev

S3:
  - Bucket: my-blog-dev-static-site
  - All objects (45 files, 2.3 MB)

CloudFront:
  - Distribution: E1234567890ABC
  - Domain: d1234567890abc.cloudfront.net

ACM (us-east-1):
  - Certificate: arn:aws:acm:us-east-1:111111111111:certificate/xxx

Route53:
  - A Record: dev.example.com → CloudFront
  - CNAME: _abc123.dev.example.com (validation)

⚠️  THIS ACTION CANNOT BE UNDONE!
```

### Step 4: Confirm destruction

Use AskUserQuestion:
"Are you sure you want to destroy all resources?"
- "No, cancel" (Recommended) - Abort destruction
- "Yes, destroy everything" - Proceed with destruction

If "Yes" selected, require typed confirmation:
"Type 'destroy' to confirm:"

### Step 5: Delete Route53 records

```bash
if [ -n "$DOMAIN_NAME" ] && [ "$DOMAIN_NAME" != "null" ]; then
  HOSTED_ZONE_ID=$(jq -r ".environments.$ENV.hostedZoneId" "$CONFIG_FILE")

  echo "Deleting Route53 records..."

  # Delete A record alias
  aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch '{
      "Changes": [{
        "Action": "DELETE",
        "ResourceRecordSet": {
          "Name": "'"$DOMAIN_NAME"'",
          "Type": "A",
          "AliasTarget": {
            "HostedZoneId": "Z2FDTNDATAQYW2",
            "DNSName": "'"$DIST_DOMAIN"'",
            "EvaluateTargetHealth": false
          }
        }
      }]
    }' \
    --profile "$PROFILE"
fi
```

### Step 6: Disable and delete CloudFront distribution

```bash
if [ -n "$DIST_ID" ]; then
  echo "Disabling CloudFront distribution..."

  # Get current config
  ETAG=$(aws cloudfront get-distribution-config \
    --id "$DIST_ID" \
    --profile "$PROFILE" \
    --query 'ETag' \
    --output text)

  # Disable distribution
  aws cloudfront get-distribution-config --id "$DIST_ID" --profile "$PROFILE" \
    | jq '.DistributionConfig.Enabled = false' \
    | aws cloudfront update-distribution --id "$DIST_ID" --if-match "$ETAG" \
      --distribution-config file:///dev/stdin --profile "$PROFILE"

  echo "Waiting for distribution to be disabled (this may take several minutes)..."
  aws cloudfront wait distribution-deployed --id "$DIST_ID" --profile "$PROFILE"

  # Delete distribution
  ETAG=$(aws cloudfront get-distribution-config \
    --id "$DIST_ID" \
    --profile "$PROFILE" \
    --query 'ETag' \
    --output text)

  aws cloudfront delete-distribution \
    --id "$DIST_ID" \
    --if-match "$ETAG" \
    --profile "$PROFILE"

  echo "✓ CloudFront distribution deleted"
fi
```

### Step 7: Delete ACM certificate

```bash
if [ -n "$CERT_ARN" ]; then
  echo "Deleting ACM certificate..."

  aws acm delete-certificate \
    --certificate-arn "$CERT_ARN" \
    --region us-east-1 \
    --profile "$PROFILE"

  echo "✓ ACM certificate deleted"
fi
```

### Step 8: Empty and delete S3 bucket

```bash
echo "Emptying S3 bucket..."

aws s3 rm "s3://$BUCKET_NAME" --recursive --profile "$PROFILE"

echo "Deleting S3 bucket..."

aws s3api delete-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --profile "$PROFILE"

echo "✓ S3 bucket deleted"
```

### Step 9: Clean up local configuration

Use AskUserQuestion:
"Delete local configuration?"
- "Yes" - Remove .claude/yaccp/aws-static-site/
- "No" - Keep configuration for re-deployment

### Step 10: Display summary

```
Destruction Complete
====================

Deleted resources:
✓ Route53 records (dev.example.com)
✓ CloudFront distribution (E1234567890ABC)
✓ ACM certificate
✓ S3 bucket (my-blog-dev-static-site)

Local configuration: Preserved

To redeploy, run:
/yaccp-aws-static-site:deploy
```

# Installation

## Prerequisites

Before installing the AWS Static Site plugin, ensure you have:

### Required

- **Claude Code CLI** - [Installation guide](https://claude.ai/code)
- **AWS CLI v2** - [Installation guide](https://aws.amazon.com/cli/)
- **AWS Account** - With permissions to create S3, CloudFront, ACM, Route53 resources

### Optional

- **Node.js 18+** - Required for Astro, 11ty, Next.js
- **Hugo** - If using Hugo SSG
- **Domain in Route53** - For custom domain configuration

## Installation

### From Plugin Registry

```bash
claude plugin add yaccp/claude-plugin-aws-static-site
```

### From GitHub

```bash
# Clone the repository
git clone https://github.com/yaccp/claude-plugin-aws-static-site.git

# Install locally
claude plugin add ./claude-plugin-aws-static-site
```

## Verify Installation

```bash
# List installed plugins
claude plugin list

# Check plugin health
/yaccp-aws-static-site:doctor
```

## AWS Configuration

### Configure AWS CLI

```bash
# Configure default profile
aws configure

# Or configure named profile
aws configure --profile my-profile
```

### Required Permissions

The plugin requires the following AWS permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutBucketPolicy",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation"
      ],
      "Resource": ["arn:aws:s3:::*-static-site", "arn:aws:s3:::*-static-site/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudfront:CreateDistribution",
        "cloudfront:UpdateDistribution",
        "cloudfront:DeleteDistribution",
        "cloudfront:CreateInvalidation",
        "cloudfront:ListDistributions",
        "cloudfront:GetDistribution",
        "cloudfront:CreateOriginAccessControl"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "acm:RequestCertificate",
        "acm:DescribeCertificate",
        "acm:DeleteCertificate",
        "acm:ListCertificates"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "us-east-1"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets",
        "route53:GetHostedZone"
      ],
      "Resource": "arn:aws:route53:::hostedzone/*"
    }
  ]
}
```

## Quick Start

After installation:

```bash
# 1. Configure environment
/yaccp-aws-static-site:env

# 2. Initialize project
/yaccp-aws-static-site:init

# 3. Build your site
# (e.g., hugo --minify)

# 4. Deploy
/yaccp-aws-static-site:deploy
```

## Troubleshooting

### Plugin not found

```bash
# Refresh plugin cache
claude plugin refresh

# Reinstall
claude plugin remove yaccp-aws-static-site
claude plugin add yaccp/claude-plugin-aws-static-site
```

### AWS credentials error

```bash
# Check current identity
aws sts get-caller-identity

# For SSO profiles
aws sso login --profile my-profile
```

## Uninstallation

```bash
claude plugin remove yaccp-aws-static-site
```

**Note**: This does not delete AWS resources. Use `/yaccp-aws-static-site:destroy` before uninstalling to clean up AWS resources.

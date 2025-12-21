# AWS Static Site

> Deploy static sites to S3 + CloudFront with custom domains and SSL.

[![Yaccp Plugin](https://img.shields.io/badge/Yaccp-Plugin-blue)](https://github.com/yaccp/yaccp)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![AWS](https://img.shields.io/badge/AWS-S3%20%2B%20CloudFront-orange)](https://aws.amazon.com)

**AWS Static Site** is a Claude Code plugin that automates static site deployment on AWS. It supports Hugo, Astro, 11ty, Next.js static export, and plain HTML sites with S3 hosting, CloudFront CDN, custom domains, and automatic SSL certificates.

## Features

- **Multiple SSGs** - Hugo, Astro, 11ty, Next.js, plain HTML
- **CloudFront CDN** - Global edge caching with gzip compression
- **Custom Domains** - Route53 integration with auto SSL (ACM)
- **Multi-Environment** - Deploy to dev/staging/prod independently
- **Cache Invalidation** - One-command CloudFront cache purge
- **Interactive Setup** - Guided configuration with prompts

## Quick Start

### Installation

```bash
claude plugin add yaccp/claude-plugin-aws-static-site
```

### Usage

```bash
# 1. Configure environment
/yaccp-aws-static-site:env

# 2. Initialize project
/yaccp-aws-static-site:init

# 3. Build your site (e.g., hugo --minify)

# 4. Deploy to AWS
/yaccp-aws-static-site:deploy
```

## Commands

| Command | Description |
|---------|-------------|
| `/yaccp-aws-static-site:env` | Manage AWS environments (dev/staging/prod) |
| `/yaccp-aws-static-site:init` | Initialize project with SSG detection |
| `/yaccp-aws-static-site:deploy` | Build and deploy to S3 + CloudFront |
| `/yaccp-aws-static-site:status` | Check infrastructure status |
| `/yaccp-aws-static-site:doctor` | Diagnose configuration issues |
| `/yaccp-aws-static-site:invalidate` | Invalidate CloudFront cache |
| `/yaccp-aws-static-site:destroy` | Destroy all AWS resources |

## Interactive Prompts

Each command guides you through configuration with interactive prompts:

<details>
<summary><strong>/yaccp-aws-static-site:init</strong></summary>

```
? Which static site generator are you using?
● Hugo (Recommended)
○ Astro
○ 11ty (Eleventy)
○ Next.js (Static Export)
○ None / Plain HTML
```

```
Configuration Summary
=====================
Static Site Generator: Hugo
Build Command:         hugo --minify
Output Directory:      public/

AWS Configuration:
Site Name:             my-blog
S3 Bucket:             my-blog-static-site
CloudFront:            Standard (Price Class 100)

Domain Configuration:
Custom Domain:         www.example.com
SSL Certificate:       ACM (auto-provisioned)

Proceed with initialization?
● Yes, create the project
○ No, let me change something
```
</details>

<details>
<summary><strong>/yaccp-aws-static-site:deploy</strong></summary>

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
</details>

<details>
<summary><strong>/yaccp-aws-static-site:status</strong></summary>

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

CloudFront Distribution
-----------------------
Distribution ID: E1234567890ABC
Status:          Deployed
Domain:          d1234567890abc.cloudfront.net

SSL Certificate
---------------
Domain:          dev.example.com
Status:          ISSUED
Expires:         2025-12-21

Health Check
------------
CloudFront URL:  200 OK (45ms)
Custom Domain:   200 OK (52ms)
```
</details>

<details>
<summary><strong>/yaccp-aws-static-site:doctor</strong></summary>

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
✓ Credentials:   Valid

AWS Resources
-------------
✓ S3 Bucket:     my-blog-dev-static-site
✓ CloudFront:    E1234567890ABC
✓ ACM Cert:      ISSUED

Status: All OK
```
</details>

<details>
<summary><strong>/yaccp-aws-static-site:destroy</strong></summary>

```
⚠️  DESTRUCTION WARNING
======================

This will PERMANENTLY DELETE:

S3:
  - Bucket: my-blog-dev-static-site
  - All objects (45 files, 2.3 MB)

CloudFront:
  - Distribution: E1234567890ABC

ACM:
  - Certificate for dev.example.com

Route53:
  - A Record: dev.example.com → CloudFront

⚠️  THIS ACTION CANNOT BE UNDONE!
```

```
? Are you sure? Type 'destroy' to confirm: destroy
```
</details>

## Architecture

![Architecture](assets/diagrams/architecture.svg)

## Workflow

![Workflow](assets/diagrams/workflow.svg)

## Multi-Environment Support

The plugin supports multiple AWS environments for professional deployment workflows:

```
.claude/yaccp/aws-static-site/config.json
├── environments/
│   ├── dev      → dev.example.com
│   ├── staging  → staging.example.com
│   └── prod     → www.example.com
└── currentEnvironment: "dev"
```

Each environment can have:
- Separate AWS accounts/profiles
- Different S3 buckets and CloudFront distributions
- Independent SSL certificates and DNS records

Use `/yaccp-aws-static-site:env` to manage environments, or override with:
```bash
export PLUGIN_ENV=staging
/yaccp-aws-static-site:deploy
```

## Static Site Generators

### Hugo
```
Build Command:    hugo --minify
Output Directory: public/
```

### Astro
```
Build Command:    npm run build
Output Directory: dist/
```

### 11ty (Eleventy)
```
Build Command:    npx @11ty/eleventy
Output Directory: _site/
```

### Next.js (Static Export)
```
Build Command:    npm run build && npm run export
Output Directory: out/
```

## Security

AWS Static Site implements AWS security best practices:

- **Private S3 buckets** - No public access, CloudFront uses Origin Access Control
- **HTTPS enforced** - All traffic encrypted with TLS 1.2+
- **ACM certificates** - Auto-provisioned and auto-renewed SSL
- **IAM least privilege** - Minimal permissions for all operations
- **DNS validation** - Secure certificate validation via Route53

## AWS Resources Created

| Resource | Description | Region |
|----------|-------------|--------|
| S3 Bucket | Static file storage | Your region |
| CloudFront Distribution | CDN with edge caching | Global |
| ACM Certificate | SSL/TLS certificate | us-east-1 |
| Route53 Records | DNS configuration | Global |
| Origin Access Control | Secure S3 access | Your region |

## Cost Estimation

Typical costs for a blog (~10K visitors/month):

| Service | Estimated Cost/Month |
|---------|---------------------|
| S3 Storage (100MB) | ~$0.05 |
| CloudFront (10GB transfer) | ~$1.00 |
| Route53 Hosted Zone | ~$0.50 |
| ACM Certificate | Free |
| **Total** | **~$2.00/month** |

*CloudFront pricing varies by region and traffic. Free tier includes 1TB/month for first year.*

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Certificate pending | DNS validation required | Add CNAME record shown in `/status` |
| 403 Forbidden | S3 bucket policy | Check OAC configuration |
| 504 Gateway Timeout | CloudFront origin error | Verify S3 bucket exists |
| Stale content | CloudFront cache | Run `/yaccp-aws-static-site:invalidate` |
| Build failed | Missing dependencies | Run `npm install` or check SSG docs |

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Static Site

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'

      - name: Build
        run: hugo --minify

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-west-1

      - name: Deploy to S3
        run: aws s3 sync public/ s3://my-blog-static-site --delete

      - name: Invalidate CloudFront
        run: |
          aws cloudfront create-invalidation \
            --distribution-id ${{ secrets.CLOUDFRONT_ID }} \
            --paths "/*"
```

## Advanced Usage

### Environment Variables

| Variable | Required | Description | Example |
|----------|----------|-------------|---------|
| `AWS_PROFILE` | Yes | AWS CLI profile | `dev-profile` |
| `AWS_REGION` | Yes | AWS region | `eu-west-1` |
| `PLUGIN_ENV` | No | Override environment | `staging` |

### CloudFront Price Classes

| Price Class | Edge Locations | Cost |
|-------------|---------------|------|
| PriceClass_100 | US, Canada, Europe | Lowest |
| PriceClass_200 | + Asia, Africa, Middle East | Medium |
| PriceClass_All | All edge locations | Highest |

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

## Author

Created by [Cyril Feraudet](https://github.com/feraudet) - A [Yaccp](https://github.com/yaccp) plugin for Claude Code.

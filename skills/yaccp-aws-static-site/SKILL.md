# AWS Static Site Deployment Skill

Deploy and manage static sites on AWS S3 + CloudFront with custom domains and SSL.

## When to Use This Skill

Use this skill when the user wants to:
- Deploy a static site (Hugo, Astro, 11ty, Next.js static export, plain HTML)
- Host a website on AWS with CloudFront CDN
- Configure custom domains with SSL certificates
- Manage S3 buckets for web hosting
- Invalidate CloudFront cache

## Capabilities

### Static Site Generators Supported
- **Hugo** - Fast Go-based SSG
- **Astro** - Modern island architecture
- **11ty (Eleventy)** - Flexible JavaScript SSG
- **Next.js** - Static export mode
- **Plain HTML/CSS/JS** - No build step required

### AWS Resources Managed
- S3 buckets with website configuration
- CloudFront distributions with OAC
- ACM SSL certificates (us-east-1)
- Route53 DNS records
- Origin Access Control for S3

### Multi-Environment Support
Manage separate environments with isolated AWS resources:
- dev → dev.example.com
- staging → staging.example.com
- prod → www.example.com

## Commands

| Command | Purpose |
|---------|---------|
| `/yaccp-aws-static-site:env` | Manage AWS environments |
| `/yaccp-aws-static-site:init` | Initialize project with SSG detection |
| `/yaccp-aws-static-site:deploy` | Build and deploy to S3 + CloudFront |
| `/yaccp-aws-static-site:status` | Check infrastructure status |
| `/yaccp-aws-static-site:doctor` | Diagnose issues |
| `/yaccp-aws-static-site:invalidate` | Invalidate CloudFront cache |
| `/yaccp-aws-static-site:destroy` | Remove all AWS resources |

## Workflow

```
1. /yaccp-aws-static-site:env        → Configure AWS environment
2. /yaccp-aws-static-site:init       → Initialize project (detect SSG, configure build)
3. [Build your site]                  → Run your SSG build command
4. /yaccp-aws-static-site:deploy     → Upload to S3, create CloudFront, configure DNS
5. /yaccp-aws-static-site:status     → Verify deployment
```

## Configuration

The plugin stores configuration in `.claude/yaccp/aws-static-site/config.json`:

```json
{
  "currentEnvironment": "dev",
  "generator": "hugo",
  "buildCommand": "hugo --minify",
  "outputDirectory": "public",
  "environments": {
    "dev": {
      "awsProfile": "dev-profile",
      "awsRegion": "eu-west-1",
      "siteName": "my-blog-dev",
      "domainName": "dev.example.com",
      "hostedZoneId": "Z1234567890ABC",
      "priceClass": "PriceClass_100"
    }
  }
}
```

## AWS Architecture

```
User Request
    │
    ▼
Route53 (A Record Alias)
    │
    ▼
CloudFront Distribution
├── SSL/TLS termination
├── Edge caching
└── Gzip compression
    │
    ▼
S3 Bucket (Origin)
├── Static files
├── Private (OAC access only)
└── Versioned (optional)
```

## Best Practices Applied

- **Security**: S3 buckets are private; CloudFront uses Origin Access Control
- **Performance**: Assets cached with long TTL, HTML with short TTL
- **Cost**: Price Class 100 by default (US, Canada, Europe)
- **SSL**: Auto-provisioned ACM certificates with DNS validation
- **CI/CD**: Compatible with GitHub Actions, GitLab CI

## Error Handling

The plugin handles common issues:
- Invalid AWS credentials → Prompt for `aws sso login`
- Missing Route53 zone → Guide through hosted zone creation
- Certificate validation pending → Show DNS record to add
- CloudFront propagation → Wait with progress indicator

## Pricing Estimate

For a typical blog (~10K visitors/month):

| Service | Monthly Cost |
|---------|-------------|
| S3 Storage | ~$0.05 |
| CloudFront | ~$1.00 |
| Route53 | ~$0.50 |
| **Total** | **~$2/month** |

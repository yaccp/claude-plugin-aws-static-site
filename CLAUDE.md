# AWS Static Site - Claude Context

## Plugin Overview

Deploy static sites to AWS S3 + CloudFront with custom domains and SSL.

Supports Hugo, Astro, 11ty, Next.js static export, and plain HTML.

## Commands

| Command | Purpose |
|---------|---------|
| `/yaccp-aws-static-site:yaccp-aws-static-site-env` | Manage AWS environments (dev/staging/prod) |
| `/yaccp-aws-static-site:yaccp-aws-static-site-init` | Initialize project with SSG detection |
| `/yaccp-aws-static-site:yaccp-aws-static-site-deploy` | Build and deploy to S3 + CloudFront |
| `/yaccp-aws-static-site:yaccp-aws-static-site-status` | Check infrastructure status |
| `/yaccp-aws-static-site:yaccp-aws-static-site-doctor` | Diagnose configuration issues |
| `/yaccp-aws-static-site:yaccp-aws-static-site-invalidate` | Invalidate CloudFront cache |
| `/yaccp-aws-static-site:yaccp-aws-static-site-destroy` | Destroy all AWS resources |

## Key Files

```
.claude-plugin/
├── plugin.json           # Plugin metadata
└── marketplace.json      # Marketplace listing

commands/
├── yaccp-aws-static-site-env.md
├── yaccp-aws-static-site-init.md
├── yaccp-aws-static-site-deploy.md
├── yaccp-aws-static-site-status.md
├── yaccp-aws-static-site-doctor.md
├── yaccp-aws-static-site-invalidate.md
└── yaccp-aws-static-site-destroy.md

skills/yaccp-aws-static-site/
└── SKILL.md

assets/diagrams/
├── architecture.mmd
├── architecture.svg
├── workflow.mmd
└── workflow.svg
```

## Configuration Storage

Commands persist configuration to: `.claude/yaccp/aws-static-site/config.json`

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
      "siteName": "my-site-dev",
      "domainName": "dev.example.com",
      "hostedZoneId": "Z1234567890ABC"
    }
  }
}
```

## AWS Resources

| Resource | Purpose |
|----------|---------|
| S3 Bucket | Static file storage |
| CloudFront | CDN distribution |
| ACM Certificate | SSL/TLS (us-east-1) |
| Route53 Records | DNS configuration |
| Origin Access Control | Secure S3 access |

## Workflow

1. `env` - Configure AWS environment
2. `init` - Detect SSG, configure build settings
3. Build site locally
4. `deploy` - Upload to S3, create CloudFront, configure DNS
5. `status` - Verify deployment
6. `invalidate` - Clear cache after updates

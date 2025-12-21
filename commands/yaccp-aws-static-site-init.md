# AWS Static Site: Initialize Project

Initialize a new static site project with S3 + CloudFront deployment configuration.

## Prerequisites

- AWS CLI configured with valid credentials
- Node.js 18+ (for build tools)
- Domain name with Route53 hosted zone (optional)

---

## Interactive Flow

### Step 1: Check prerequisites

```bash
# Check AWS CLI
aws --version

# Check Node.js
node --version

# Check if already initialized
if [ -f ".claude/yaccp/aws-static-site/config.json" ]; then
  echo "Project already initialized"
fi
```

### Step 2: Select static site generator

Use AskUserQuestion:
"Which static site generator are you using?"
- "Hugo" (Recommended) - Fast, Go-based SSG
- "Astro" - Modern, island architecture
- "11ty (Eleventy)" - Simple, flexible JavaScript SSG
- "Next.js (Static Export)" - React-based with static export
- "None / Plain HTML" - Static HTML/CSS/JS files

### Step 3: Configure build settings

Based on generator selection:

**Hugo:**
```
Build Command:    hugo --minify
Output Directory: public/
```

**Astro:**
```
Build Command:    npm run build
Output Directory: dist/
```

**11ty:**
```
Build Command:    npx @11ty/eleventy
Output Directory: _site/
```

**Next.js:**
```
Build Command:    npm run build && npm run export
Output Directory: out/
```

**Plain HTML:**
```
Build Command:    (none)
Output Directory: ./
```

Use AskUserQuestion to confirm or customize:
"Build settings:"
- "Use defaults" (Recommended)
- "Customize build command"
- "Customize output directory"

### Step 4: Configure site details

Use AskUserQuestion:
"Site name (used for S3 bucket and CloudFront):"
- Free text input, validate: lowercase, alphanumeric, hyphens

Use AskUserQuestion:
"Custom domain? (leave empty for CloudFront default)"
- Free text input, e.g., www.example.com

If custom domain provided:
Use AskUserQuestion:
"Route53 Hosted Zone ID for {domain}:"
- Free text input

### Step 5: Select CloudFront configuration

Use AskUserQuestion:
"CloudFront configuration:"
- "Standard" (Recommended) - Price class 100, basic caching
- "Global" - All edge locations, higher cost
- "Minimal" - US/EU only, lowest cost

### Step 6: Confirmation

Display summary:
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
Hosted Zone:           Z1234567890ABC

Proceed with initialization?
● Yes, create the project
○ No, let me change something
```

### Step 7: Create configuration files

Create `.claude/yaccp/aws-static-site/config.json`:
```json
{
  "currentEnvironment": "dev",
  "generator": "hugo",
  "buildCommand": "hugo --minify",
  "outputDirectory": "public",
  "environments": {
    "dev": {
      "awsProfile": "default",
      "awsRegion": "eu-west-1",
      "siteName": "my-blog-dev",
      "domainName": "dev.example.com",
      "hostedZoneId": "Z1234567890ABC",
      "priceClass": "PriceClass_100"
    }
  }
}
```

Create `.gitignore` entries if needed:
```
.claude/yaccp/aws-static-site/config.json
```

### Step 8: Display next steps

```
Initialization Complete!
========================

Your static site is configured for AWS deployment.

Next steps:
1. Build your site:        hugo --minify
2. Deploy to AWS:          /yaccp-aws-static-site:deploy
3. Check status:           /yaccp-aws-static-site:status

Resources that will be created:
- S3 bucket: my-blog-dev-static-site
- CloudFront distribution
- ACM SSL certificate (if custom domain)
- Route53 records (if custom domain)
```

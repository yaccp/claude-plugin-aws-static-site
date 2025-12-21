# AWS Static Site: Environment Management

Manage AWS environments (dev/staging/prod) for static site deployment.

## Configuration File

Path: `.claude/yaccp/aws-static-site/config.json`

```json
{
  "currentEnvironment": "dev",
  "environments": {
    "dev": {
      "awsProfile": "dev-profile",
      "awsRegion": "eu-west-1",
      "awsAccountId": "111111111111",
      "siteName": "my-site-dev",
      "domainName": "dev.example.com",
      "hostedZoneId": "Z1234567890ABC"
    }
  }
}
```

---

## Interactive Flow

### Step 1: Check existing configuration

```bash
CONFIG_FILE=".claude/yaccp/aws-static-site/config.json"
if [ -f "$CONFIG_FILE" ]; then
  cat "$CONFIG_FILE"
fi
```

### Step 2: Select action

Use AskUserQuestion:
"What would you like to do?"
- "View current environment" - Display active configuration
- "Switch environment" - Change active environment
- "Add new environment" - Configure a new environment
- "Edit environment" - Modify existing environment settings

### Step 3a: View current environment

Display formatted environment info:

```
Current Environment: dev
=====================
AWS Profile:    dev-profile
AWS Region:     eu-west-1
AWS Account:    111111111111

Site Configuration:
Site Name:      my-site-dev
Domain:         dev.example.com
Hosted Zone:    Z1234567890ABC
```

### Step 3b: Switch environment

Use AskUserQuestion:
"Select environment:"
- "dev" - Development environment
- "staging" - Staging environment
- "prod" - Production environment

Update `currentEnvironment` in config.json.

### Step 3c: Add new environment

Use AskUserQuestion for each field:

1. "Environment name?" - dev, staging, prod, or custom
2. "AWS Profile name?" - Profile configured in ~/.aws/credentials
3. "AWS Region?" - eu-west-1, us-east-1, etc.
4. "Site name?" - Unique identifier for the site
5. "Domain name?" - e.g., www.example.com
6. "Route53 Hosted Zone ID?" - For DNS validation

Validate AWS credentials:
```bash
aws sts get-caller-identity --profile <profile>
```

Create/update config.json with new environment.

### Step 3d: Edit environment

Use AskUserQuestion:
"Which environment to edit?"
- List existing environments

Then ask which fields to modify.

---

## Output Examples

### Success
```
Environment 'staging' added successfully!

staging:
  AWS Profile:    staging-profile
  AWS Region:     eu-west-1
  AWS Account:    222222222222
  Site Name:      my-site-staging
  Domain:         staging.example.com
```

### Error
```
Error: AWS credentials not valid for profile 'invalid-profile'

Run: aws configure --profile invalid-profile
```

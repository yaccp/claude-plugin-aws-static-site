# aws-static-site - Claude Context

## Plugin Overview

Deploy static sites with CI/CD (Hugo, Astro, 11ty)

## Commands

| Command | Purpose |
|---------|---------|
| `/aws-static-site:env` | Manage environments |

## Key Files

```
.claude-plugin/
├── plugin.json
└── marketplace.json

commands/
├── env.md

skills/aws-static-site/
└── SKILL.md
```

## Configuration Storage

Commands persist configuration to: `.claude/yaccp/aws-static-site/config.json`

---
name: aws-static-site
autoContext: always
---

# Aws Static Site

Host static sites on AWS with CDN and SSL

## IMPORTANT: Environment Discovery

**ALWAYS start by reading the configuration:**

```bash
cat .claude/yaccp/aws-static-site/config.json 2>/dev/null || echo '{}'
```

This determines the current state and available options.

## State Machine

Based on config.json content:

| State | Condition | Action |
|-------|-----------|--------|
| `NO_CONFIG` | File missing or empty | → First time setup |
| `CONFIGURED` | Valid config exists | → Show main menu |

## State: NO_CONFIG

Use AskUserQuestion:
- **"Commencer la configuration"** → Collect required parameters
- **"Voir la documentation"** → Show plugin help

After configuration, save to:
```bash
mkdir -p .claude/yaccp/aws-static-site
# Write config.json with collected parameters
```

## State: CONFIGURED

Use AskUserQuestion:
- **"▶️ Exécuter"** → Run main action
- **"⚙️ Configuration"** → Modify settings  
- **"📊 Statut"** → Show current state
- **"❓ Aide"** → Documentation

## After Each Action

Always offer:
- **"Retour au menu"** → Back to main menu
- **"Quitter"** → End session

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Plugin Overview

**Aws Static Site** - Deploy static sites to AWS S3 + CloudFront with custom domains and SSL

## Command

Single entry point with interactive menu:

```
/aws-static-site:aws-static-site
```

This command handles all operations through AskUserQuestion menus.

## Configuration

All configuration stored in `.claude/yaccp/aws-static-site/config.json`.

## Key Files

```
aws-static-site/
├── .claude-plugin/
│   └── plugin.json       # Plugin metadata
├── commands/
│   └── aws-static-site.md         # Single entry point command
├── skills/
│   └── aws-static-site/
│       └── SKILL.md
└── CLAUDE.md
```

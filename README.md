# aws-static-site

Deploy static sites to AWS S3 + CloudFront with custom domains and SSL

## Installation

```bash
claude plugin add yaccp/aws-static-site
```

## Usage

Ce plugin est **auto-découvert**. Décrivez simplement votre besoin :

```
"Je veux configurer aws static site"
```

Claude activera automatiquement le plugin et vous guidera via des menus interactifs.

## Configuration

Toute la configuration est stockée dans :

```
.claude/yaccp/aws-static-site/config.json
```

## Structure

```
aws-static-site/
├── .claude-plugin/
│   └── plugin.json       # Métadonnées
├── skills/
│   └── aws-static-site/
│       └── SKILL.md      # Workflow complet
└── CLAUDE.md             # Guide Claude
```

## License

Apache-2.0

---
name: aws-static-site
autoContext: always
---

# AWS Static Site

Host static sites on AWS with CDN and SSL

## Configuration

All configuration is stored in `.claude/yaccp/aws-static-site/config.json`.

## Workflow

### Step 1: Load State

Read existing configuration:
```bash
cat .claude/yaccp/aws-static-site/config.json 2>/dev/null
```

Determine current state:
- **NO_CONFIG**: No configuration → First time setup
- **CONFIGURED**: Configuration exists → Show main menu

### Step 2: Display Status

```
╔═══════════════════════════════════════════════════════════╗
║                            AWS Static Site               ║
╠═══════════════════════════════════════════════════════════╣
║        Host static sites on AWS with CDN and SSL       ║
╚═══════════════════════════════════════════════════════════╝
```

### Step 3: Route Based on State

---

## State: NO_CONFIG (First Time)

Use AskUserQuestion:
```
question: "Bienvenue! C'est votre première utilisation. Configurons le plugin."
options:
  - label: "Commencer la configuration"
    description: "Configurer les paramètres nécessaires"
  - label: "Voir la documentation"
    description: "En savoir plus sur ce plugin"
```

### Configuration initiale

Use AskUserQuestion:
```
question: "Quel profil AWS utiliser?"
options: [Lister les profils depuis ~/.aws/credentials]
```

Use AskUserQuestion:
```
question: "Domaine du site? (ex: www.example.com)"
options: [text input]
```

Use AskUserQuestion:
```
question: "Quel environnement?"
options:
  - label: "dev (Développement)"
  - label: "staging (Pré-production)"
  - label: "prod (Production)"
```

Sauvegarder dans config.json:
```bash
mkdir -p .claude/yaccp/aws-static-site
```

→ Retour au menu principal

---

## State: CONFIGURED (Menu Principal)

Use AskUserQuestion:
```
question: "Que souhaitez-vous faire?"
options:
  - label: "🚀 Déployer le site"
    description: "Builder et déployer vers AWS"
  - label: "📊 Voir le statut"
    description: "État de l'infrastructure"
  - label: "🔄 Changer d'environnement"
    description: "Passer à dev/staging/prod"
  - label: "⚙️ Configuration"
    description: "Modifier les paramètres"
  - label: "🏗️ Créer l'infrastructure"
    description: "Provisionner S3, CloudFront, SSL"
  - label: "🗑️ Détruire l'infrastructure"
    description: "Supprimer les ressources AWS"
```

---

### Action: Déployer le site

1. Builder le projet
2. Uploader vers S3
3. Invalider le cache CloudFront

### Action: Créer l'infrastructure

1. Créer S3 bucket (privé)
2. Créer certificat ACM
3. Créer distribution CloudFront
4. Configurer Route53

---

## Boucle de Fin

Après chaque action, toujours proposer:

Use AskUserQuestion:
```
question: "Action terminée. Que faire?"
options:
  - label: "Retour au menu principal"
    description: "Continuer à utiliser le plugin"
  - label: "Quitter"
    description: "Fin de session"
```

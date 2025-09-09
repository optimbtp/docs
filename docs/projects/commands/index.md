# Documentation du Projet Commands

![Status](https://img.shields.io/badge/Statut-Actif-green) ![Type](https://img.shields.io/badge/Type-Outils%20CLI-blue)

Bienvenue dans la documentation du projet Commands. Cette section couvre nos utilitaires en ligne de commande et nos outils d'automatisation.

## Aperçu

Le projet Commands fournit une suite d'outils en ligne de commande conçus pour rationaliser les tâches de développement, de déploiement et opérationnelles dans l'écosystème Optim.

## Commandes Disponibles

### Commandes Principales

- **`docker build`** - Automatisation de construction et packaging
- **`docker compose up -d`** - Lancement des conteneurs
- **`docker compose down`** - Fermeture des conteneurs

### Commandes de Développement

- **`optim-dev`** - Configuration de l'environnement de développement
- **`optim-lint`** - Qualité de code et linting
- **`optim-format`** - Utilitaires de formatage de code
- **`optim-analyze`** - Analyse de code et métriques -->

### Commandes d'Opérations

<!--
- **`optim-monitor`** - Surveillance système et vérifications de santé
- **`optim-backup`** - Utilitaires de sauvegarde et restauration
- **`optim-migrate`** - Migrations de base de données et système
- **`optim-scale`** - Gestion de la mise à l'échelle et des charges -->

## Démarrage Rapide

### Installation

<!-- ```bash
# Installation globale
npm install -g @optim/commands

# Installation spécifique au projet
npm install --save-dev @optim/commands
``` -->

### Utilisation de Base

```bash
# Afficher l'aide
optim --help

# Vérifier la version
optim --version

# Construire le projet
optim-build --env production

# Exécuter les tests
optim-test --coverage

# Déployer l'application
optim-deploy --target staging
```

## Référence des Commandes

### Commandes de Construction

```bash
# Construire avec un environnement spécifique
optim-build --env [development|staging|production]

# Construire avec une configuration personnalisée
optim-build --config ./custom-build.json

# Construire avec sortie détaillée
optim-build --verbose

# Nettoyer les artefacts de construction
optim-build --clean
```

### Commandes de Test

```bash
# Exécuter tous les tests
optim-test

# Exécuter une suite de tests spécifique
optim-test --suite unit

# Exécuter avec couverture
optim-test --coverage

# Exécuter en mode surveillance
optim-test --watch

# Générer un rapport de test
optim-test --report html
```

### Commandes de Déploiement

```bash
# Déployer vers staging
optim-deploy --target staging

# Déployer avec capacité de rollback
optim-deploy --target production --enable-rollback

# Déploiement en mode simulation
optim-deploy --dry-run

# Déployer une version spécifique
optim-deploy --version 1.2.3

# Effectuer un rollback
optim-deploy --rollback
```

## Configuration

### Configuration Globale

Créer un fichier de configuration globale à `~/.optim/config.json` :

```json
{
  "defaultEnvironment": "development",
  "buildOutputDir": "./dist",
  "testTimeout": 30000,
  "deploymentTargets": {
    "staging": {
      "url": "https://staging.optim.com",
      "apiKey": "staging-api-key"
    },
    "production": {
      "url": "https://optim.com",
      "apiKey": "production-api-key"
    }
  }
}
```

### Configuration de Projet

Créer un fichier de configuration spécifique au projet à `./optim.json` :

```json
{
  "name": "mon-projet",
  "version": "1.0.0",
  "build": {
    "entry": "./src/index.js",
    "outputDir": "./dist",
    "sourceMap": true
  },
  "test": {
    "testDir": "./tests",
    "coverage": {
      "threshold": 80
    }
  },
  "deploy": {
    "beforeDeploy": ["optim-test", "optim-build"],
    "afterDeploy": ["optim-monitor --health-check"]
  }
}
```

## Utilisation Avancée

### Scripts Personnalisés

<!-- ```bash
# Créer une commande personnalisée
optim-config create-command ma-commande-personnalisee

# Exécuter un script personnalisé
optim run mon-script-personnalise

# Chaîner plusieurs commandes
optim run "build && test && deploy"
``` -->

### Variables d'Environnement

```bash
# Définir des variables spécifiques à l'environnement
export OPTIM_ENV=production
export OPTIM_API_KEY=votre-cle-api
export OPTIM_LOG_LEVEL=debug

# Utiliser dans les commandes
optim-deploy --env $OPTIM_ENV
```

### Hooks et Plugins

```bash
# Installer un plugin
optim-config install-plugin @optim/eslint-plugin

# Configurer des hooks
optim-config set-hook pre-commit "optim-lint && optim-test"

# Exécuter les hooks manuellement
optim-config run-hook pre-deploy
```

## Exemples d'Intégration

### Intégration CI/CD

```yaml
# Exemple GitHub Actions
name: Déployer
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Configurer Node.js
        uses: actions/setup-node@v2
        with:
          node-version: "16"
      - name: Installer les dépendances
        run: npm ci
      - name: Installer Optim CLI
        run: npm install -g @optim/commands
      - name: Exécuter les tests
        run: optim-test --coverage
      - name: Construire l'application
        run: optim-build --env production
      - name: Déployer
        run: optim-deploy --target production
        env:
          OPTIM_API_KEY: ${{ secrets.OPTIM_API_KEY }}
```

### Intégration Docker

```dockerfile
# Exemple Dockerfile
FROM node:16-alpine

# Installer Optim CLI
RUN npm install -g @optim/commands

# Copier les fichiers du projet
COPY . /app
WORKDIR /app

# Installer les dépendances
RUN npm ci

# Construire l'application
RUN optim-build --env production

# Démarrer l'application
CMD ["optim", "run", "start"]
```

## Dépannage

### Problèmes Courants

1. **Commande Introuvable**

   ```bash
   # Assurer l'installation globale
   npm install -g @optim/commands

   # Vérifier le PATH
   echo $PATH
   ```

2. **Erreurs de Permission**

   ```bash
   # Utiliser sudo pour l'installation globale
   sudo npm install -g @optim/commands

   # Ou configurer le préfixe npm
   npm config set prefix ~/.npm-global
   ```

3. **Échecs de Construction**

   ```bash
   # Nettoyer et reconstruire
   optim-build --clean
   optim-build --verbose

   # Vérifier les dépendances
   npm audit
   ```

### Mode Debug

```bash
# Activer la journalisation de debug
export DEBUG=optim:*
optim-build --verbose

# Vérifier la configuration
optim-config show

# Valider l'environnement
optim-config validate
```

## Développement

### Contribuer

1. Forker le dépôt
2. Créer une branche de fonctionnalité
3. Implémenter les changements avec des tests
4. Soumettre une pull request

### Développement Local

```bash
# Cloner le dépôt
git clone https://github.com/optim/commands.git
cd commands

# Installer les dépendances
npm install

# Lier pour les tests locaux
npm link

# Exécuter les tests
npm test

# Construire
npm run build
```

### Créer de Nouvelles Commandes

```javascript
// lib/commands/ma-commande.js
const { Command } = require("@optim/commands-core");

class MaCommande extends Command {
  constructor() {
    super("ma-commande", "Description de ma commande");

    this.option("-f, --force", "Forcer l'exécution");
    this.option("-o, --output <dir>", "Répertoire de sortie");
  }

  async execute(options) {
    // Implémentation de la commande
    console.log("Exécution de ma commande avec les options:", options);
  }
}

module.exports = MaCommande;
```

## Référence API

### Classes Principales

- **`Command`** - Classe de base pour toutes les commandes
- **`Config`** - Gestion de la configuration
- **`Logger`** - Utilitaires de journalisation
- **`Utils`** - Fonctions utilitaires communes

### Système de Hooks

- **`pre-build`** - Avant l'exécution de la construction
- **`post-build`** - Après la completion de la construction
- **`pre-test`** - Avant l'exécution des tests
- **`post-test`** - Après la completion des tests
- **`pre-deploy`** - Avant le déploiement
- **`post-deploy`** - Après le déploiement

## Ressources

- **[Dépôt GitHub](https://github.com/optim/commands)**
- **[Documentation API](api/index.md)**
- **[Dépôt d'Exemples](https://github.com/optim/commands-examples)**
- **[Registre de Plugins](plugins/index.md)**

---

_Pour les questions ou le support, contactez l'Équipe Outils ou créez un ticket dans le dépôt._

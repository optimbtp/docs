# 📚 Centre de Documentation Optim

![MkDocs](https://img.shields.io/badge/MkDocs-Material-blue)
![Status](https://img.shields.io/badge/Status-Actif-green)
![Language](https://img.shields.io/badge/Langue-Français-blue)

Documentation complète et centralisée pour tous les projets de l'écosystème Optim.

## 🚀 Démarrage Rapide

### Prérequis

- Python 3.8+
- pip

### Installation

```bash
# Cloner le dépôt
git clone https://github.com/azer-optim/docs.git
cd docs

# Créer l'environnement virtuel
python -m venv .venv
source .venv/bin/activate  # Linux/Mac
# ou .venv\Scripts\activate  # Windows

# Installer les dépendances
pip install mkdocs-material

# Lancer le serveur de développement
mkdocs serve
```

📖 **Accès:** [http://127.0.0.1:8000](http://127.0.0.1:8000)

## 📁 Structure du Projet

```
docs/
├── projects/           # Documentation des projets
│   ├── mobile/        # Application mobile
│   ├── saas/          # Plateforme SAAS
│   ├── backoffice/    # Interface d'administration
│   └── commands/      # Outils CLI
├── shared/            # Ressources partagées
│   ├── infrastructure/ # Documentation infrastructure
│   ├── standards/     # Standards de développement
│   └── tools/         # Outils et configuration
└── mkdocs.yml         # Configuration MkDocs
```

## 🎯 Fonctionnalités

- ✅ **Documentation Multi-Projets** - Mobile, SAAS, Backoffice, Commands
- ✅ **Infrastructure K8s** - Procédures et snippets de code
- ✅ **Mode Sombre/Clair** - Interface adaptative
- ✅ **Recherche Intégrée** - Recherche full-text en français
- ✅ **Navigation Intuitive** - Organisation par onglets
- ✅ **Responsive Design** - Compatible mobile et desktop

## 📖 Sections Principales

| Section                                                   | Description                       |
| --------------------------------------------------------- | --------------------------------- |
| **[Projets](docs/projects/index.md)**                     | Documentation des applications    |
| **[Infrastructure](docs/shared/infrastructure/index.md)** | Kubernetes, Docker, CI/CD         |
| **[Standards](docs/shared/standards/index.md)**           | Bonnes pratiques de développement |
| **[Outils](docs/shared/tools/index.md)**                  | Configuration et outillage        |

## 🛠️ Commandes Utiles

```bash
# Serveur de développement
mkdocs serve

# Construction statique
mkdocs build

# Déploiement
mkdocs gh-deploy
```

## 🤝 Contribution

1. **Fork** le dépôt
2. **Créer** une branche: `git checkout -b feature/nouvelle-doc`
3. **Commit** vos changements: `git commit -m "Ajout documentation X"`
4. **Push** vers la branche: `git push origin feature/nouvelle-doc`
5. **Créer** une Pull Request

## 📋 Standards de Documentation

- ✅ **Français** comme langue principale
- ✅ **Format Markdown** pour tous les contenus
- ✅ **Exemples de code** avec commentaires
- ✅ **Procédures étape par étape** pour les tâches complexes
- ✅ **Screenshots** pour les interfaces utilisateur

## 🚀 Déploiement Production

```bash
# Construction et déploiement
mkdocs build
mkdocs gh-deploy --force
```

## 📞 Support

- **Repository:** [azer-optim/docs](https://github.com/azer-optim/docs)
- **Issues:** [Créer un ticket](https://github.com/azer-optim/docs/issues)
- **Équipe:** Documentation Optim

---

📅 **Dernière mise à jour:** Septembre 2025  
🏷️ **Version:** 1.0.0  
👥 **Mainteneurs:** Équipe Optim

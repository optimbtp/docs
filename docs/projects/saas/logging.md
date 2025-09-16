# Journalisation et Sentry

## Vue d'ensemble

Nous utilisons Sentry pour la collecte, l'agrégation et le suivi des erreurs côté API (FastAPI) et côté frontend (React + TypeScript). Ce document décrit la configuration, des exemples d'utilisation, le déploiement des sourcemaps / symboles et les bonnes pratiques.

Objectifs

- Capturer les exceptions non gérées et les erreurs applicatives.
- Enrichir les événements avec le contexte (utilisateur, requête, tags, transactions).
- Faciliter le debug via les stack traces et sourcemaps (frontend) / symbolication (backend).
- Fournir le suivi des performances (optionnel) via Sentry Performance.

## Concepts importants

- DSN : l'identifiant de projet Sentry (ne pas le committer dans le code public). Utiliser des variables d'environnement.
- Environnement : `production`, `recette` — utile pour filtrer les erreurs.
- Tags : paires clé/valeur pour catégoriser les événements (ex : `feature`, `region`).
- Breadcrumbs : événements menant à l'erreur (logs, requêtes, interactions utilisateur).

## Sécurité et variables d'environnement

Stocker la DSN et la configuration Sentry dans les variables d'environnement. Exemple :

- `SENTRY_DSN` — DSN publique pour l'envoi d'événements.
- `SENTRY_ENV` — environnement (`production` / `recette` ).
- `SENTRY_RELEASE` — version/release (fortement recommandé pour corréler sourcemaps et releases).

Ne pas exposer la DSN privée (si vous utilisez des clés d'authentification côté serveur). Pour le frontend, une DSN publique (client key) est attendue par Sentry.

## FastAPI — configuration et exemples

1. Installation (backend Python)

```bash
pip install sentry-sdk
```

2. Initialisation dans l'application FastAPI

Créez / modifiez l'initialisation de votre application (par exemple `app/main.py`) :

```py
import os
from fastapi import FastAPI
import sentry_sdk
from sentry_sdk.integrations.asgi import SentryAsgiMiddleware
from sentry_sdk.integrations.logging import LoggingIntegration

# Récupérer la DSN depuis l'environnement
SENTRY_DSN = os.environ.get("SENTRY_DSN")
SENTRY_ENV = os.environ.get("SENTRY_ENV", "production")
SENTRY_RELEASE = os.environ.get("SENTRY_RELEASE")

# Intégration pour capturer logs INFO/WARN/ERROR
logging_integration = LoggingIntegration(
    level=None,          # capture nothing by default from the logging module
    event_level="ERROR" # capture e.g. ERROR as events
)

sentry_sdk.init(
    dsn=SENTRY_DSN,
    environment=SENTRY_ENV,
    release=SENTRY_RELEASE,
    integrations=[logging_integration],
    # traces_sample_rate=0.1,  # activer Sentry Performance si besoin
)

app = FastAPI()
# Optionnel : middleware ASGI de Sentry pour capturer exceptions et transactions
app.add_middleware(SentryAsgiMiddleware)


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.get("/debug-sentry")
async def trigger_error():
    # Exemple : capture d'une exception non gérée
    raise RuntimeError("Test Sentry: exception déclenchée volontairement")

```

3. Capturer des exceptions manuellement et ajouter du contexte

```py
from sentry_sdk import capture_exception, set_user, set_tag

try:
    # code qui peut lever
    risky_operation()
except Exception as exc:
    # ajouter du contexte
    set_user({"id": "123", "email": "user@example.com"})
    set_tag("module", "importer")
    capture_exception(exc)
    raise
```

4. Bonnes pratiques backend

- Ne pas envoyer d'informations sensibles (mots de passe, tokens) dans les événements.
- Utiliser `SENTRY_RELEASE` lors des déploiements pour relier erreurs → release.
- Configurer le sampling `traces_sample_rate` uniquement si vous activez Performance.

## React + TypeScript — configuration et exemples

1. Installation (frontend)

```bash
npm install @sentry/react @sentry/tracing
# ou yarn add @sentry/react @sentry/tracing
```

2. Initialisation (ex : `src/sentry.ts`)

```ts
import * as Sentry from "@sentry/react";
import { BrowserTracing } from "@sentry/tracing";

Sentry.init({
  dsn: process.env.REACT_APP_SENTRY_DSN,
  environment: process.env.REACT_APP_SENTRY_ENV ?? "production",
  release: process.env.REACT_APP_SENTRY_RELEASE,
  integrations: [new BrowserTracing()],
  tracesSampleRate: 0.05, // ajuster selon le volume
  // beforeSend: (event) => { // filtrer/masquer des données sensibles
  //   return event;
  // }
});

export default Sentry;
```

3. Rattacher Sentry au tout début de l'application (ex : `src/index.tsx`)

```ts
import React from "react";
import { createRoot } from "react-dom/client";
import App from "./App";
import Sentry from "./sentry";
import { ErrorBoundary } from "@sentry/react";

const container = document.getElementById("root")!;
const root = createRoot(container);

root.render(
  <ErrorBoundary fallback={<div>Une erreur est survenue</div>}>
    <App />
  </ErrorBoundary>
);
```

4. Capturer une erreur manuellement

```ts
try {
  riskyFunction();
} catch (err) {
  Sentry.captureException(err);
}

// Ajouter du contexte utilisateur
Sentry.setUser({ id: "123", email: "user@example.com" });
Sentry.setTag("section", "checkout");

// Ajouter des breadcrumbs personnalisés
Sentry.addBreadcrumb({ message: "User clicked buy", level: "info" });
```

5. Sourcemaps et release

Pour que les stack traces JavaScript soient lisibles, il faut :

- publier un `release` dans Sentry avec la même valeur `release` que celle configurée dans l'application (ex : `my-app@1.2.3`).
- uploader les sourcemaps lors du build (ou utiliser l'intégration Sentry CLI) :

Exemple (CI) :

```bash
# installer sentry-cli (ou utiliser l'image fournie par Sentry)
npm install -g @sentry/cli

# lors du build frontend
export SENTRY_AUTH_TOKEN=...         # token stocké en CI
export SENTRY_ORG=your-org
export SENTRY_PROJECT=your-project
export SENTRY_RELEASE=my-app@1.2.3

sentry-cli releases new $SENTRY_RELEASE
sentry-cli releases files $SENTRY_RELEASE upload-sourcemaps ./build --url-prefix "~" --validate
sentry-cli releases finalize $SENTRY_RELEASE
```

Adapter l'URL prefix à votre configuration d'hébergement (ex: `~/static/js`).

6. Bonnes pratiques frontend

- Minifier le taux de traces (tracesSampleRate) pour limiter le coût.
- Filtrer données sensibles avec `beforeSend`.
- Mettre `release` et uploader sourcemaps à chaque déploiement.
- Profiter des `breadcrumbs` et `tags` pour faciliter le tri et le debug.

## Exemples d'usage concret

- Suivi d'une erreur d'API : lorsqu'une requête fetch/axios renvoie 500, capturer l'erreur, ajouter des tags (route, utilisateur) et envoyer à Sentry.
- Erreur frontend : captureException + redirection vers une page d'erreur tout en gardant le tracking dans Sentry.

Exemple fetch + Sentry :

```ts
import Sentry from "./sentry";

async function callApi(endpoint: string) {
  try {
    const res = await fetch(endpoint);
    if (!res.ok) {
      const err = new Error(`API error ${res.status}`);
      Sentry.captureException(err);
      throw err;
    }
    return await res.json();
  } catch (err) {
    Sentry.captureException(err);
    throw err;
  }
}
```

## Edge cases et points d'attention

- Volume d'événements élevés : configurer sampling, filtres et rate-limits.
- Données sensibles : appliquer `beforeSend` pour redaction.
- Environnements multiples : utiliser `environment` pour séparer les erreurs.
- Versions/release : sans `release`, les sourcemaps ne s'appliquent pas correctement.

## Résumé rapide (checklist avant déploiement)

- [ ] DSN configurée via variable d'environnement.
- [ ] `SENTRY_RELEASE` renseigné et matching entre CI et app.
- [ ] Sourcemaps uploadées pour le frontend.
- [ ] `beforeSend` implémenté si nécessaire pour filtrer les données sensibles.
- [ ] Traces sampling configuré si activation Performance.

---

Si tu veux, je peux :

- Générer des snippets plus adaptés à la structure existante du projet (donne-moi les chemins d'entrée : ex `src/main.py`, `src/index.tsx`).
- Ajouter des exemples CI/CD (GitLab CI, GitHub Actions) pour uploader automatiquement les sourcemaps.

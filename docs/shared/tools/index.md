# Outils de Développement et de Déploiement

Cette section documente les outils et utilitaires utilisés dans tous les projets Optim pour le développement, les tests et le déploiement.

## Outils de Développement

### Éditeurs de Code et IDEs

#### Visual Studio Code

**Extensions Recommandées :**

- **ESLint** - Linting JavaScript/TypeScript
- **Prettier** - Formatage de code
- **GitLens** - Capacités Git améliorées
- **Thunder Client** - Tests d'API
- **Docker** - Développement de conteneurs
- **Kubernetes** - Gestion des ressources K8s

**Configuration :**

```json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true
  },
  "typescript.preferences.importModuleSpecifier": "relative",
  "git.enableSmartCommit": true,
  "files.exclude": {
    "**/node_modules": true,
    "**/dist": true,
    "**/.git": true
  }
}
```

#### IDEs JetBrains

- **WebStorm** - Développement JavaScript/TypeScript
- **IntelliJ IDEA** - Développement Java
- **PyCharm** - Développement Python

### Contrôle de Version

#### Configuration Git

```bash
# Configuration Git globale
git config --global user.name "Votre Nom"
git config --global user.email "your.email@optim.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.autocrlf input

# Useful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
```

#### Git Hooks with Husky

```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged && npm run test:unit",
      "commit-msg": "commitlint -E HUSKY_GIT_PARAMS",
      "pre-push": "npm run test:integration"
    }
  },
  "lint-staged": {
    "*.{js,ts,tsx}": ["eslint --fix", "prettier --write"],
    "*.{css,scss,md}": ["prettier --write"]
  }
}
```

### Package Managers

#### Node.js - npm/yarn

```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint . --ext .js,.jsx,.ts,.tsx",
    "lint:fix": "eslint . --ext .js,.jsx,.ts,.tsx --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "next": "^13.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "@types/node": "^18.0.0",
    "@types/react": "^18.0.0",
    "eslint": "^8.0.0",
    "prettier": "^2.7.0",
    "typescript": "^4.8.0"
  }
}
```

#### Python - pip/poetry

```toml
# pyproject.toml
[tool.poetry]
name = "optim-api"
version = "1.0.0"
description = "Optim API Service"

[tool.poetry.dependencies]
python = "^3.9"
fastapi = "^0.95.0"
uvicorn = "^0.21.0"
sqlalchemy = "^2.0.0"
alembic = "^1.10.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.0.0"
pytest-asyncio = "^0.21.0"
black = "^23.0.0"
flake8 = "^6.0.0"
mypy = "^1.2.0"

[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

## Testing Tools

### JavaScript/TypeScript Testing

#### Jest Configuration

```javascript
// jest.config.js
module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/src", "<rootDir>/tests"],
  testMatch: [
    "**/__tests__/**/*.+(ts|tsx|js)",
    "**/*.(test|spec).+(ts|tsx|js)",
  ],
  transform: {
    "^.+\\.(ts|tsx)$": "ts-jest",
  },
  collectCoverageFrom: [
    "src/**/*.{ts,tsx}",
    "!src/**/*.d.ts",
    "!src/types/**/*",
  ],
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
};
```

#### Testing Library Setup

```typescript
// tests/setup.ts
import "@testing-library/jest-dom";
import { configure } from "@testing-library/react";

configure({ testIdAttribute: "data-testid" });

// Mock global objects
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: jest.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: jest.fn(),
    removeListener: jest.fn(),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
  })),
});
```

### Python Testing

#### Pytest Configuration

```ini
# pytest.ini
[tool:pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts =
    --strict-markers
    --strict-config
    --verbose
    --cov=src
    --cov-report=term-missing
    --cov-report=html
    --cov-fail-under=80
markers =
    unit: Unit tests
    integration: Integration tests
    e2e: End-to-end tests
    slow: Slow running tests
```

### End-to-End Testing

#### Playwright Configuration

```typescript
// playwright.config.ts
import { PlaywrightTestConfig } from "@playwright/test";

const config: PlaywrightTestConfig = {
  testDir: "./e2e",
  timeout: 30000,
  retries: 2,
  use: {
    baseURL: "http://localhost:3000",
    headless: true,
    viewport: { width: 1280, height: 720 },
    ignoreHTTPSErrors: true,
    video: "retain-on-failure",
    screenshot: "only-on-failure",
  },
  projects: [
    {
      name: "Chrome",
      use: { ...devices["Desktop Chrome"] },
    },
    {
      name: "Firefox",
      use: { ...devices["Desktop Firefox"] },
    },
    {
      name: "Safari",
      use: { ...devices["Desktop Safari"] },
    },
  ],
};

export default config;
```

## Build Tools

### Frontend Build Tools

#### Webpack Configuration

```javascript
// webpack.config.js
const path = require("path");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  entry: "./src/index.tsx",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "[name].[contenthash].js",
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: "ts-loader",
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
    ],
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./public/index.html",
    }),
    new MiniCssExtractPlugin({
      filename: "[name].[contenthash].css",
    }),
  ],
  optimization: {
    splitChunks: {
      chunks: "all",
    },
  },
};
```

#### Vite Configuration

```typescript
// vite.config.ts
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { resolve } from "path";

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": resolve(__dirname, "src"),
    },
  },
  build: {
    outDir: "dist",
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ["react", "react-dom"],
          utils: ["lodash", "date-fns"],
        },
      },
    },
  },
  server: {
    port: 3000,
    open: true,
  },
});
```

### Backend Build Tools

#### Docker Configuration

```dockerfile
# Dockerfile
FROM node:18-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:18-alpine AS runtime

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

USER nextjs

EXPOSE 3000
ENV PORT 3000

CMD ["npm", "start"]
```

#### Multi-stage Docker Build

```dockerfile
# Multi-stage Dockerfile
FROM node:18-alpine AS dependencies
WORKDIR /app
COPY package*.json ./
RUN npm ci --frozen-lockfile

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json

USER nextjs

EXPOSE 3000
ENV PORT 3000

CMD ["node", "dist/index.js"]
```

## Deployment Tools

### Container Orchestration

#### Docker Compose

```yaml
# docker-compose.yml
version: "3.8"

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://user:pass@db:5432/optim
    depends_on:
      - db
      - redis
    volumes:
      - ./src:/app/src

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: optim
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

#### Kubernetes Helm Charts

```yaml
# helm/values.yaml
replicaCount: 3

image:
  repository: optim/app
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: app.optim.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.optim.com

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

### Infrastructure as Code

#### Terraform Configuration

```hcl
# terraform/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "optim-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
}
```

## Monitoring and Debugging Tools

### Application Monitoring

#### Prometheus Configuration

```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alerts/*.yml"

scrape_configs:
  - job_name: "optim-app"
    static_configs:
      - targets: ["localhost:3000"]
    metrics_path: "/metrics"
    scrape_interval: 5s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093
```

#### Grafana Dashboard

```json
{
  "dashboard": {
    "id": null,
    "title": "Optim Application Dashboard",
    "tags": ["optim"],
    "timezone": "browser",
    "panels": [
      {
        "id": 1,
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{status}}"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
```

### Error Tracking

#### Sentry Configuration

```typescript
// sentry.client.config.ts
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 1.0,
  beforeSend(event) {
    if (event.exception) {
      const error = event.exception.values?.[0];
      if (error?.value?.includes("Non-Error")) {
        return null;
      }
    }
    return event;
  },
});
```

### Service Uptime Monitoring

#### UptimeRobot

**UptimeRobot** est notre solution principale pour surveiller la disponibilité de nos services en production. Il surveille en continu nos applications web, API et services backend pour détecter les temps d'arrêt et les problèmes de performance.

**Services Surveillés :**

- **Web App SAAS** - Application frontend React
- **Web API SAAS** - API backend FastAPI
- **Backoffice App** - Interface d'administration
- **Backoffice API** - API de gestion interne

**Fonctionnalités Principales :**

- **Surveillance 24/7** - Vérifications automatiques toutes les 5 minutes
- **Notifications Instantanées** - Alertes par email/SMS en cas de panne
- **Statistiques Détaillées** - Historique de disponibilité et temps de réponse
- **Page de Status Public** - Transparence pour les utilisateurs

**Dashboard de Monitoring :**
🔗 **[Status Page Optim](https://stats.uptimerobot.com/Oe5A4NnL2J)**

**Configuration des Alertes :**

```yaml
# Configuration type pour UptimeRobot
monitors:
  - name: "SAAS Web App"
    url: "https://ref.web.optimbtp.fr"
    type: "HTTP(s)"
    interval: 300 # 5 minutes

  - name: "SAAS API"
    url: "https://api.ref.web.optimbtp.fr/docs"
    type: "HTTP(s)"
    interval: 300

  - name: "Backoffice App"
    url: "https://admin.web.optimbtp.fr/login"
    type: "HTTP(s)"
    interval: 300

  - name: "Backoffice API"
    url: "https://api.admin.web.optimbtp.fr/admin"
    type: "HTTP(s)"
    interval: 300

alert_contacts:
  - type: "email"
    value: "technique@optim-factory.fr"
```

**Bonnes Pratiques :**

- **Endpoints de Health Check** - Implémenter des endpoints `/health` dédiés
- **Seuils d'Alerte** - Configurer des alertes après 2 échecs consécutifs
- **Escalation** - Alertes par email puis SMS si le problème persiste
- **Maintenance Windows** - Programmer les fenêtres de maintenance pour éviter les fausses alertes

**Intégration avec les Autres Outils :**

- **Slack** - Notifications dans le canal `#alerts`
- **PagerDuty** - Escalation pour les incidents critiques
- **Grafana** - Corrélation avec les métriques de performance

## Code Quality Tools

### Linting and Formatting

#### ESLint Configuration

```javascript
// .eslintrc.js
module.exports = {
  extends: [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "next/core-web-vitals",
    "prettier",
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  rules: {
    "@typescript-eslint/no-unused-vars": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "prefer-const": "error",
    "no-var": "error",
  },
};
```

#### Prettier Configuration

```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### Security Scanning

#### GitHub Security Workflows

```yaml
# .github/workflows/security.yml
name: Security Scan
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run npm audit
        run: npm audit --audit-level moderate

      - name: Run Snyk test
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

      - name: Run CodeQL Analysis
        uses: github/codeql-action/analyze@v2
        with:
          languages: javascript
```

## Utility Scripts

### Development Scripts

```bash
#!/bin/bash
# scripts/dev-setup.sh

echo "Setting up development environment..."

# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Generate SSL certificates for local development
mkcert localhost 127.0.0.1 ::1

# Start database
docker-compose up -d db redis

# Run database migrations
npm run migrate

# Seed database
npm run seed

echo "Development environment ready."
echo "Run 'npm run dev' to start the application"
```

### Deployment Scripts

```bash
#!/bin/bash
# scripts/deploy.sh

set -e

ENVIRONMENT=${1:-staging}
VERSION=${2:-latest}

echo "Deploying to $ENVIRONMENT with version $VERSION"

# Build and push Docker image
docker build -t optim/app:$VERSION .
docker push optim/app:$VERSION

# Deploy with Helm
helm upgrade --install optim-app ./helm/optim-app \
  --set image.tag=$VERSION \
  --namespace $ENVIRONMENT \
  --wait

echo "Deployment complete!"
```

## Resources and Documentation

### Tool Documentation Links

- **[Docker Documentation](https://docs.docker.com/)**
- **[Kubernetes Documentation](https://kubernetes.io/docs/)**
- **[Terraform Documentation](https://www.terraform.io/docs/)**
- **[Jest Documentation](https://jestjs.io/docs/)**
- **[Playwright Documentation](https://playwright.dev/)**

### Internal Tool Guides

- **[Development Environment Setup](development-setup.md)**
- **[Testing Best Practices](testing-guide.md)**
- **[Deployment Procedures](deployment-guide.md)**
- **[Monitoring Setup](monitoring-guide.md)**

---

_For tool-specific questions or issues, consult the respective documentation or contact the DevOps team._

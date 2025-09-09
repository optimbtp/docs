# Commands Project Documentation

![Status](https://img.shields.io/badge/Status-Active-green) ![Type](https://img.shields.io/badge/Type-CLI%20Tools-blue)

Welcome to the Commands project documentation. This section covers our command-line utilities and automation tools.

## Overview

The Commands project provides a suite of command-line tools designed to streamline development, deployment, and operational tasks across the Optim ecosystem.

## Available Commands

### Core Commands

- **`optim-build`** - Build automation and packaging
- **`optim-deploy`** - Deployment orchestration
- **`optim-test`** - Testing utilities and runners
- **`optim-sync`** - Data synchronization tools
- **`optim-config`** - Configuration management

### Development Commands

- **`optim-dev`** - Development environment setup
- **`optim-lint`** - Code quality and linting
- **`optim-format`** - Code formatting utilities
- **`optim-analyze`** - Code analysis and metrics

### Operations Commands

- **`optim-monitor`** - System monitoring and health checks
- **`optim-backup`** - Backup and restore utilities
- **`optim-migrate`** - Database and system migrations
- **`optim-scale`** - Scaling and load management

## Quick Start

### Installation

```bash
# Global installation
npm install -g @optim/commands

# Project-specific installation
npm install --save-dev @optim/commands
```

### Basic Usage

```bash
# Display help
optim --help

# Check version
optim --version

# Build project
optim-build --env production

# Run tests
optim-test --coverage

# Deploy application
optim-deploy --target staging
```

## Command Reference

### Build Commands

```bash
# Build with specific environment
optim-build --env [development|staging|production]

# Build with custom configuration
optim-build --config ./custom-build.json

# Build with verbose output
optim-build --verbose

# Clean build artifacts
optim-build --clean
```

### Test Commands

```bash
# Run all tests
optim-test

# Run specific test suite
optim-test --suite unit

# Run with coverage
optim-test --coverage

# Run in watch mode
optim-test --watch

# Generate test report
optim-test --report html
```

### Deployment Commands

```bash
# Deploy to staging
optim-deploy --target staging

# Deploy with rollback capability
optim-deploy --target production --enable-rollback

# Dry run deployment
optim-deploy --dry-run

# Deploy specific version
optim-deploy --version 1.2.3

# Rollback deployment
optim-deploy --rollback
```

## Configuration

### Global Configuration

Create a global configuration file at `~/.optim/config.json`:

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

### Project Configuration

Create a project-specific configuration file at `./optim.json`:

```json
{
  "name": "my-project",
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

## Advanced Usage

### Custom Scripts

```bash
# Create custom command
optim-config create-command my-custom-command

# Run custom script
optim run my-custom-script

# Chain multiple commands
optim run "build && test && deploy"
```

### Environment Variables

```bash
# Set environment-specific variables
export OPTIM_ENV=production
export OPTIM_API_KEY=your-api-key
export OPTIM_LOG_LEVEL=debug

# Use in commands
optim-deploy --env $OPTIM_ENV
```

### Hooks and Plugins

```bash
# Install plugin
optim-config install-plugin @optim/eslint-plugin

# Configure hooks
optim-config set-hook pre-commit "optim-lint && optim-test"

# Run hooks manually
optim-config run-hook pre-deploy
```

## Integration Examples

### CI/CD Integration

```yaml
# GitHub Actions example
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: "16"
      - name: Install dependencies
        run: npm ci
      - name: Install Optim CLI
        run: npm install -g @optim/commands
      - name: Run tests
        run: optim-test --coverage
      - name: Build application
        run: optim-build --env production
      - name: Deploy
        run: optim-deploy --target production
        env:
          OPTIM_API_KEY: ${{ secrets.OPTIM_API_KEY }}
```

### Docker Integration

```dockerfile
# Dockerfile example
FROM node:16-alpine

# Install Optim CLI
RUN npm install -g @optim/commands

# Copy project files
COPY . /app
WORKDIR /app

# Install dependencies
RUN npm ci

# Build application
RUN optim-build --env production

# Start application
CMD ["optim", "run", "start"]
```

## Troubleshooting

### Common Issues

1. **Command Not Found**

   ```bash
   # Ensure global installation
   npm install -g @optim/commands

   # Check PATH
   echo $PATH
   ```

2. **Permission Errors**

   ```bash
   # Use sudo for global installation
   sudo npm install -g @optim/commands

   # Or configure npm prefix
   npm config set prefix ~/.npm-global
   ```

3. **Build Failures**

   ```bash
   # Clean and rebuild
   optim-build --clean
   optim-build --verbose

   # Check dependencies
   npm audit
   ```

### Debug Mode

```bash
# Enable debug logging
export DEBUG=optim:*
optim-build --verbose

# Check configuration
optim-config show

# Validate environment
optim-config validate
```

## Development

### Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

### Local Development

```bash
# Clone repository
git clone https://github.com/optim/commands.git
cd commands

# Install dependencies
npm install

# Link for local testing
npm link

# Run tests
npm test

# Build
npm run build
```

### Creating New Commands

```javascript
// lib/commands/my-command.js
const { Command } = require("@optim/commands-core");

class MyCommand extends Command {
  constructor() {
    super("my-command", "Description of my command");

    this.option("-f, --force", "Force execution");
    this.option("-o, --output <dir>", "Output directory");
  }

  async execute(options) {
    // Command implementation
    console.log("Executing my command with options:", options);
  }
}

module.exports = MyCommand;
```

## API Reference

### Core Classes

- **`Command`** - Base class for all commands
- **`Config`** - Configuration management
- **`Logger`** - Logging utilities
- **`Utils`** - Common utility functions

### Hooks System

- **`pre-build`** - Before build execution
- **`post-build`** - After build completion
- **`pre-test`** - Before test execution
- **`post-test`** - After test completion
- **`pre-deploy`** - Before deployment
- **`post-deploy`** - After deployment

## Resources

- **[GitHub Repository](https://github.com/optim/commands)**
- **[API Documentation](api/index.md)**
- **[Examples Repository](https://github.com/optim/commands-examples)**
- **[Plugin Registry](plugins/index.md)**

---

_For questions or support, contact the Tools Team or create an issue in the repository._

# Pulumi v2 Infrastructure Setup

Infrastructure as Code (IaC) alternative to Docker Compose for the self-hosted development platform.

## Status: 🚧 Work in Progress

Setting up Pulumi v2 to manage the same services as the main Portainer setup, but with programmatic control.

## Why Pulumi over Docker Compose?

- **Type Safety**: Use TypeScript/Python/Go with full IDE support
- **State Management**: Track infrastructure changes and rollback if needed
- **Multi-Cloud**: Deploy to AWS, Azure, GCP, or local Docker
- **Secrets Management**: Built-in encrypted secrets handling
- **Preview Changes**: See what will change before applying
- **Programmatic Control**: Use loops, conditions, and functions

## Overview

This Pulumi project manages:
- All services from the main docker-compose setup
- Docker containers and networks
- Volume management and persistence
- Service dependencies and health checks
- Environment configuration

## Prerequisites

```bash
# 1. Install Pulumi CLI
curl -fsSL https://get.pulumi.com | sh

# 2. Install Node.js (for TypeScript)
# macOS: brew install node
# Linux: sudo apt install nodejs npm

# 3. Install dependencies
cd pulumiv2
npm install
```

## Quick Start

```bash
# 1. Login to Pulumi (use local backend for self-hosted)
pulumi login --local

# 2. Create a new stack
pulumi stack init dev

# 3. Configure the stack
pulumi config set docker:host unix:///var/run/docker.sock

# 4. Preview what will be created
pulumi preview

# 5. Deploy the infrastructure
pulumi up

# 6. View stack outputs
pulumi stack output
```

## Project Structure

```
pulumiv2/
├── README.md             # This file
├── Pulumi.yaml          # Project metadata
├── Pulumi.dev.yaml      # Development environment config
├── index.ts             # Main infrastructure code
├── package.json         # Node.js dependencies
├── tsconfig.json        # TypeScript configuration
└── stacks/              # Environment-specific configs
    ├── dev.ts           # Development settings
    └── prod.ts          # Production settings
```

## Current Services

The `index.ts` file currently defines:
- Portainer for Docker management
- Custom Docker network
- Volume management

### Planned Services to Add

From the main docker-compose setup:
- [ ] Traefik reverse proxy
- [ ] Uptime Kuma monitoring
- [ ] PostgreSQL database
- [ ] MySQL database
- [ ] Redis cache
- [ ] Adminer database UI
- [ ] Additional services from template

## Usage Examples

### View Current Infrastructure
```bash
pulumi stack
```

### Update a Service
```typescript
// Edit index.ts to change container version
const portainer = new docker.Container("portainer", {
    image: "portainer/portainer-ce:2.19.4", // Specific version
    // ...
});
```

### Add a New Service
```typescript
// Add PostgreSQL to index.ts
const postgres = new docker.Container("postgres", {
    image: "postgres:16-alpine",
    envs: [
        "POSTGRES_USER=admin",
        "POSTGRES_PASSWORD=${pulumiConfig.require('postgresPassword')}",
        "POSTGRES_DB=platform",
    ],
    ports: [{
        internal: 5432,
        external: 5432,
    }],
    volumes: [{
        containerPath: "/var/lib/postgresql/data",
        hostPath: "postgres_data",
    }],
    networksAdvanced: [{
        name: network.name,
    }],
});
```

### Destroy Infrastructure
```bash
# Preview what will be destroyed
pulumi destroy --preview

# Destroy everything
pulumi destroy
```

## Environment Management

```bash
# List all stacks
pulumi stack ls

# Switch environments
pulumi stack select prod

# Copy config between stacks
pulumi config cp --dest prod
```

## Secrets Management

```bash
# Set a secret
pulumi config set --secret dbPassword mySecretPass

# Use in code
const dbPassword = config.requireSecret("dbPassword");
```

## Comparison with Docker Compose

| Feature | Docker Compose | Pulumi |
|---------|---------------|--------|
| Configuration | YAML | TypeScript/Python/Go |
| State Management | None | Built-in with history |
| Secrets | Environment files | Encrypted in state |
| Multi-Environment | Multiple files | Stacks |
| Rollback | Manual | `pulumi stack history` |
| Type Safety | No | Yes |
| IDE Support | Basic | Full IntelliSense |

## Troubleshooting

### Permission Denied on Docker Socket
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Pulumi Command Not Found
```bash
export PATH=$PATH:$HOME/.pulumi/bin
```

### TypeScript Errors
```bash
npm install
npm run build
```

## Next Steps

1. Complete service migrations from docker-compose
2. Add health checks and restart policies
3. Implement backup automation
4. Add monitoring and alerting
5. Create production-ready configurations

## Resources

- [Pulumi Docker Provider](https://www.pulumi.com/registry/packages/docker/)
- [Pulumi TypeScript Guide](https://www.pulumi.com/docs/languages-sdks/typescript/)
- [Main Project README](../README.md)
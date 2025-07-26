#!/bin/bash
set -e

echo "🚀 Docker Infrastructure Setup"
echo "=============================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "❌ This script should not be run as root"
   exit 1
fi

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env exists
if [[ ! -f .env ]]; then
    echo "📋 Creating environment file from template..."
    cp .env.example .env
    echo "✅ Created .env file"
    echo "⚠️  Please edit .env with your configuration before continuing"
    echo ""
    echo "Required changes:"
    echo "  - DOMAIN=yourdomain.com"
    echo "  - ACME_EMAIL=your-email@yourdomain.com"
    echo "  - Update all passwords"
    echo ""
    echo "Run 'nano .env' to edit, then run this script again"
    exit 0
fi

# Source environment variables
source .env

# Validate required variables
if [[ "$DOMAIN" == "yourdomain.com" ]]; then
    echo "❌ Please update DOMAIN in .env file"
    exit 1
fi

if [[ "$ACME_EMAIL" == "your-email@yourdomain.com" ]]; then
    echo "❌ Please update ACME_EMAIL in .env file"
    exit 1
fi

echo "🔧 Setting up Docker networks..."
docker network create traefik_network 2>/dev/null || echo "Network traefik_network already exists"

echo "🔐 Setting correct permissions..."
chmod +x scripts/db-management/*.sh
chmod +x scripts/*.sh

echo "📁 Creating necessary directories..."
mkdir -p traefik/data
mkdir -p backups
mkdir -p logs

echo "🏗️  Building and starting services..."
echo "Starting Traefik first..."
docker-compose -f traefik/docker-compose.yml up -d

echo "Waiting for Traefik to be ready..."
sleep 10

echo "Starting main services..."
docker-compose up -d

echo ""
echo "✅ Setup complete!"
echo ""
echo "🌐 Your services will be available at:"
echo "  - Traefik Dashboard: https://${TRAEFIK_SUBDOMAIN}.${DOMAIN}"
echo "  - Portainer:         https://${PORTAINER_SUBDOMAIN}.${DOMAIN}"
echo "  - UptimeKuma:        https://${UPTIME_SUBDOMAIN}.${DOMAIN}"
echo "  - ntfy:              https://${NTFY_SUBDOMAIN}.${DOMAIN}"
echo "  - Database UI:       https://${DB_SUBDOMAIN}.${DOMAIN}"
echo ""
echo "📝 Next steps:"
echo "  1. Configure DNS records (see docs/deployment.md)"
echo "  2. Wait for SSL certificates to be issued (~2 minutes)"
echo "  3. Access services and complete their setup"
echo ""
echo "🔧 Useful commands:"
echo "  make status    - Check service status"
echo "  make logs      - View logs"
echo "  make backup    - Create backup"
echo "  make help      - See all available commands"
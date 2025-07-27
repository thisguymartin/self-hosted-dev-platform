#!/bin/bash
set -e

echo "🚀 Docker Infrastructure Setup"
echo "=============================="

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
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
    exit 0
fi

# Source environment variables
set -a
source .env
set +a

echo "🔧 Setting up Docker network..."
docker network create traefik_network 2>/dev/null || true

echo "📁 Creating necessary directories..."
mkdir -p traefik/data/logs
mkdir -p backups
touch traefik/data/acme.json
chmod 600 traefik/data/acme.json

echo "🏗️  Starting services..."
docker compose -f traefik/docker-compose.yml up -d
sleep 5
docker compose up -d

echo ""
echo "✅ Setup complete!"
echo ""
echo "🌐 Your services are available at:"
echo "  - Traefik Dashboard: http://localhost:8888"
echo "  - Portainer:         http://localhost:9000"
echo "  - Uptime Kuma:       http://localhost:3001"
echo "  - Database UI:       http://localhost:8080"
echo ""
echo "📝 If accessing from another machine, replace 'localhost' with your server IP"
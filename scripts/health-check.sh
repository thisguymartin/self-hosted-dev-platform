#!/bin/bash

echo "🏥 Service Health Check"
echo "====================="

# Check Docker services
echo ""
echo "📦 Docker Services:"
docker compose ps --format "table {{.Name}}\t{{.Status}}"

# Check core services specifically
echo ""
echo "🔧 Core Services:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(traefik|portainer)" || echo "Core services not running"

# Check if any template services are running
echo ""
echo "📋 Additional Services (from template):"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -vE "(traefik|portainer)" | tail -n +2 || echo "None running"

echo ""
echo "💡 To add more services, use docker-compose.template.yml"
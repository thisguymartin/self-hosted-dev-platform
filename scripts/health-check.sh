#!/bin/bash

echo "🏥 Service Health Check"
echo "====================="

# Check Docker services
echo ""
echo "📦 Docker Services:"
docker compose ps --format "table {{.Name}}\t{{.Status}}"

# Check databases
echo ""
echo "🗄️  Databases:"
docker exec postgres_main pg_isready &>/dev/null && echo "✅ PostgreSQL" || echo "❌ PostgreSQL"
docker exec mysql_main mysqladmin ping &>/dev/null 2>&1 && echo "✅ MySQL" || echo "❌ MySQL"

# List any additional test databases
echo ""
echo "🧪 Test Databases:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(postgres|mysql|mongo|redis)_test" || echo "None running"
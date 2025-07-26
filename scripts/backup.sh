#!/bin/bash
set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="infrastructure_backup_${TIMESTAMP}"

echo "🔄 Starting backup process..."

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop services for consistent backup
echo "⏸️  Stopping services..."
docker-compose stop

# Backup Docker volumes
echo "💾 Backing up Docker volumes..."
docker run --rm \
    -v docker-infrastructure_portainer_data:/source/portainer:ro \
    -v docker-infrastructure_uptimekuma_data:/source/uptimekuma:ro \
    -v docker-infrastructure_ntfy_data:/source/ntfy:ro \
    -v docker-infrastructure_postgres_data:/source/postgres:ro \
    -v docker-infrastructure_mysql_data:/source/mysql:ro \
    -v docker-infrastructure_traefik_data:/source/traefik:ro \
    -v "$PWD/$BACKUP_DIR":/backup \
    alpine:latest tar czf "/backup/${BACKUP_NAME}_volumes.tar.gz" -C /source .

# Backup database data
echo "🗄️  Backing up database data..."
docker-compose start postgres mysql
sleep 10

# PostgreSQL backup
docker exec postgres_main pg_dump -U testuser testdb > "$BACKUP_DIR/${BACKUP_NAME}_postgres.sql"

# MySQL backup
docker exec mysql_main mysqldump -u testuser -ptestpassword123 testdb > "$BACKUP_DIR/${BACKUP_NAME}_mysql.sql"

# Backup configuration files
echo "⚙️  Backing up configuration..."
tar czf "$BACKUP_DIR/${BACKUP_NAME}_config.tar.gz" \
    docker-compose.yml \
    traefik/ \
    .env \
    scripts/

# Restart services
echo "▶️  Restarting services..."
docker-compose up -d

# Cleanup old backups (keep last 30 days)
echo "🧹 Cleaning up old backups..."
find "$BACKUP_DIR" -name "infrastructure_backup_*" -mtime +30 -delete

echo "✅ Backup completed: $BACKUP_NAME"
echo "📁 Backup location: $BACKUP_DIR/"
echo "📊 Backup size: $(du -sh "$BACKUP_DIR/${BACKUP_NAME}"* | awk '{total+=$1} END {print total "B"}')"
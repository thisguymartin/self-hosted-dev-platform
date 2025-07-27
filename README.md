# Self-Hosted Development Platform

Simple Docker setup with monitoring and databases - ready in 2 minutes! No domain needed.

## 🚀 Quick Start

### 1. Clone & Setup

```bash
git clone <your-repo-url>
cd self-hosted-dev-platform

# Run setup
./scripts/setup.sh
```

That's it! Your platform is running.

## 📦 What's Included

### Core Services (Main Setup)

| Service | URL | Purpose |
|---------|-----|---------|
| **Traefik** | `http://YOUR-IP:8888` | Reverse proxy dashboard |
| **Portainer** | `http://YOUR-IP:9000` | Docker management UI |

### Additional Services (Template)

The `docker-compose.template.yml` file includes additional services you can add:

| Service | Default Port | Purpose |
|---------|-------------|------|
| **Uptime Kuma** | `:3001` | Service monitoring |
| **Adminer** | `:8080` | Database management UI |
| **PostgreSQL** | `:5432` | PostgreSQL database |
| **MySQL** | `:3306` | MySQL database |
| **GitLab CE** | `:80`, `:2222` (SSH) | Git repository manager |
| **Redis** | `:6379` | In-memory data store |
| **Elasticsearch** | `:9200` | Search engine |
| **Kibana** | `:5601` | Elasticsearch dashboard |
| **Nextcloud** | `:80` | File hosting |

Replace `YOUR-IP` with:
- `localhost` if accessing from the same machine
- Your server's IP address if accessing remotely

## 🧪 Adding Additional Services

### Using the Template

The project includes a `docker-compose.template.yml` with many useful services. To add services:

1. **Option 1: Copy services to your main compose file**
   ```bash
   # Copy the service definition you need from docker-compose.template.yml
   # to your docker-compose.yml
   ```

2. **Option 2: Create an override file**
   ```bash
   # Create docker-compose.override.yml with the services you want
   # Docker Compose will automatically merge both files
   ```

3. **Option 3: Run template directly**
   ```bash
   # For testing purposes
   docker compose -f docker-compose.yml -f docker-compose.template.yml up -d
   ```

### Example: Add Uptime Kuma

1. Copy the Uptime Kuma service from `docker-compose.template.yml`
2. Add it to your `docker-compose.yml` or create a `docker-compose.override.yml`
3. Run `docker compose up -d`
4. Access at `http://YOUR-IP:3001`

## 🛠️ Common Commands

```bash
make status    # Check service health
make logs      # View logs
make stop      # Stop everything
make start     # Start everything
make health    # Quick health check
```

## 🔧 Database Access

### Default Credentials

When using services from the template, edit these in `.env` before first run:

**PostgreSQL:**
- User: `postgres` (or set `POSTGRES_USER`)
- Password: `changeme` (set `POSTGRES_PASSWORD`)
- Database: `myapp` (or set `POSTGRES_DB`)
- Port: `5432`

**MySQL:**
- User: `mysql` (or set `MYSQL_USER`)
- Password: `changeme` (set `MYSQL_PASSWORD`)
- Database: `myapp` (or set `MYSQL_DATABASE`)
- Port: `3306`

### Connection Examples

```bash
# PostgreSQL
psql -h YOUR-IP -U devuser -d devdb

# MySQL
mysql -h YOUR-IP -u devuser -p devdb

# From Docker containers
# Use hostnames: postgres or mysql
```

### From Adminer UI (if added from template)

1. Visit `http://YOUR-IP:8080`
2. Select system: PostgreSQL or MySQL
3. Server: `postgres` or `mysql`
4. Use credentials from `.env`

## 🐛 Troubleshooting

### Can't access services?

```bash
# Check if services are running
make status

# Check logs
make logs

# Check specific service
docker logs portainer_main
```

### Firewall blocking access?

```bash
# Allow ports (Ubuntu/Debian)
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw allow 8888  # Traefik dashboard
sudo ufw allow 9000  # Portainer

# If using services from template:
sudo ufw allow 3001  # Uptime Kuma
sudo ufw allow 8080  # Adminer
sudo ufw allow 5432  # PostgreSQL
sudo ufw allow 3306  # MySQL
```

### Port already in use?

Edit `docker-compose.yml` and change the port mapping:
```yaml
ports:
  - "9001:9000"  # Change 9001 to any free port
```

## 📝 Tips

- **Change passwords** in `.env` before deploying
- **Use the template file** (`docker-compose.template.yml`) to see available services
- **Keep core services minimal** - only Traefik and Portainer in main setup
- **Use Portainer** at `http://YOUR-IP:9000` to manage containers visually
- **Add monitoring** like Uptime Kuma from the template when needed

## 🤝 Need Help?

1. Check service logs: `docker logs <container_name>`
2. Verify ports aren't blocked by firewall
3. Ensure Docker is running: `docker ps`
4. Create an issue if stuck!
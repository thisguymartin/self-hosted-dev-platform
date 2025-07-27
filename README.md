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

| Service | URL | Purpose |
|---------|-----|---------|
| **Traefik** | `http://YOUR-IP:8888` | Reverse proxy dashboard |
| **Portainer** | `http://YOUR-IP:9000` | Docker management UI |
| **Uptime Kuma** | `http://YOUR-IP:3001` | Service monitoring |
| **Adminer** | `http://YOUR-IP:8080` | Database management UI |
| **PostgreSQL** | `YOUR-IP:5432` | PostgreSQL database |
| **MySQL** | `YOUR-IP:3306` | MySQL database |

Replace `YOUR-IP` with:
- `localhost` if accessing from the same machine
- Your server's IP address if accessing remotely

## 🧪 Adding Test Databases

Super easy! Just copy and edit:

```bash
cp docker-compose.override.yml.example docker-compose.override.yml
nano docker-compose.override.yml  # Uncomment what you need
docker compose up -d
```

### Available Test Databases

The override file includes templates for:
- **PostgreSQL** (port 5433)
- **MySQL** (port 3307) 
- **MongoDB** (port 27017)
- **Redis** (port 6379)
- **MariaDB** (port 3308)

### Example: Add MongoDB

1. Edit `docker-compose.override.yml`
2. Uncomment the MongoDB section
3. Run `docker compose up -d`
4. Connect to `YOUR-IP:27017`

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

Edit these in `.env` before first run:

**PostgreSQL:**
- User: `devuser`
- Password: `changeme123`
- Database: `devdb`
- Port: `5432`

**MySQL:**
- User: `devuser`
- Password: `changeme123`
- Database: `devdb`
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

### From Adminer UI

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
sudo ufw allow 8888  # Traefik
sudo ufw allow 9000  # Portainer
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
- **Use override file** for test databases to keep main compose clean
- **Check Uptime Kuma** at `http://YOUR-IP:3001` to monitor all services
- **Use Portainer** at `http://YOUR-IP:9000` to manage containers visually

## 🤝 Need Help?

1. Check service logs: `docker logs <container_name>`
2. Verify ports aren't blocked by firewall
3. Ensure Docker is running: `docker ps`
4. Create an issue if stuck!
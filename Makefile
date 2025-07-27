.PHONY: help setup start stop restart logs status clean health

# Default environment
ENV ?= development

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup: ## Initial setup - copy env file and create networks
	@echo "Setting up infrastructure..."
	@cp .env.example .env
	@echo "Please edit .env with your configuration"
	@docker network create traefik_network 2>/dev/null || true
	@echo "Setup complete! Edit .env and run 'make start'"

start: ## Start all services
	@./scripts/setup.sh

stop: ## Stop all services
	@echo "Stopping services..."
	@docker compose down
	@docker compose -f traefik/docker-compose.yml down

restart: ## Restart all services
	@make stop
	@make start

status: ## Show service status
	@echo "=== Service Status ==="
	@docker compose ps
	@echo ""
	@echo "=== Traefik Status ==="
	@docker compose -f traefik/docker-compose.yml ps

logs: ## Show logs for all services
	@docker compose logs -f

traefik-logs: ## Show Traefik logs
	@docker compose -f traefik/docker-compose.yml logs -f

clean: ## Remove all containers, volumes, and networks
	@echo "Warning: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose down -v; \
		docker compose -f traefik/docker-compose.yml down -v; \
		docker system prune -f; \
	fi

health: ## Run health check
	@./scripts/health-check.sh

update: ## Pull latest images and restart
	@echo "Updating services..."
	@docker compose pull
	@docker compose -f traefik/docker-compose.yml pull
	@make restart

ssl-status: ## Check SSL certificate status
	@echo "Checking SSL certificates..."
	@docker exec traefik traefik version
	@echo "Check Traefik dashboard for certificate details"
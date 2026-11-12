-include .env.local
COMPOSE := docker compose
BRANCH ?= main

.PHONY: help up down logs test status deploy rollback vps-setup prod-status prod-logs ssh-vps

help: ## Ayuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "%-14s %s\n", $$1, $$2}'

up: ## Levanta la landing en local: http://localhost:8040
	$(COMPOSE) up -d --build
	@echo "Listo: http://localhost:$${PORT:-8040}"

down: ## Baja el local
	$(COMPOSE) down

logs: ## Logs del local
	$(COMPOSE) logs -f

status: ## Estado del local
	$(COMPOSE) ps

test: ## Valida el HTML y que el contenedor lo sirve (build + health + título)
	@test -s index.html || { echo "FALTA index.html"; exit 1; }
	@grep -q "<title>" index.html || { echo "index.html sin <title>"; exit 1; }
	@PORT=8049 $(COMPOSE) -p elecciones-test up -d --build
	@ok=0; for i in $$(seq 1 20); do curl -fs http://127.0.0.1:8049/healthz >/dev/null && ok=1 && break; sleep 1; done; \
	  if [ $$ok = 1 ] && curl -fs http://127.0.0.1:8049/ | grep -q "<title>"; then echo "OK"; r=0; else echo "FALLO el smoke local"; r=1; fi; \
	  $(COMPOSE) -p elecciones-test down >/dev/null 2>&1; exit $$r

# ─── Producción (VPS compartido; ver docs/produccion.md). Corre desde la PC del ingeniero. ───
vps-setup: ## Prepara el VPS (clona el repo y instala el vhost). Idempotente. Después: make deploy FIRST=1 y certbot (docs/produccion.md)
	ssh $(SERVER) 'set -e; [ -d $(DEPLOY_PATH)/.git ] || git clone git@github.com:orgullorojocom-arch/elecciones.git $(DEPLOY_PATH); \
	  cd $(DEPLOY_PATH) && git fetch -q --all --tags && git checkout -q origin/$(BRANCH); \
	  [ -f /etc/nginx/conf.d/elecciones-active-color.conf ] || printf "upstream elecciones_front { server 127.0.0.1:3140; }\n" | sudo tee /etc/nginx/conf.d/elecciones-active-color.conf >/dev/null; \
	  [ -e /etc/nginx/sites-enabled/elecciones.orgullorojo.com ] || sudo cp deploy/nginx/elecciones.orgullorojo.com.conf /etc/nginx/sites-enabled/elecciones.orgullorojo.com; \
	  sudo nginx -t'

deploy: ## Actualiza main y despliega blue/green (uso: make deploy [TAG=x] [FIRST=1])
	@git fetch -q origin $(BRANCH) && git checkout -q $(BRANCH) && git pull -q --ff-only origin $(BRANCH)
	@$(MAKE) test
	@T=$${TAG:-deploy-$$(date -u +%Y%m%d-%H%M)}; \
	  git tag -a $$T -m "Deploy $$T" && git push -q origin $$T && \
	  echo "Desplegando $$T ($$(git rev-parse --short HEAD)) en $(SERVER)..." && \
	  ssh $(SERVER) "cd $(DEPLOY_PATH) && git fetch -q --all --tags && git checkout -q $$T && SKIP_PUBLIC=$${SKIP_PUBLIC:-0} scripts/deploy-bluegreen.sh $$T $(if $(FIRST),--first)"
	@$(MAKE) --no-print-directory prod-status

rollback: ## Vuelve al color anterior (sigue arriba): instantáneo
	ssh $(SERVER) 'cd $(DEPLOY_PATH) && a=$$(cat .bluegreen/active) && if [ $$a = blue ]; then o=green; else o=blue; fi && scripts/switch-color.sh $$o'
	@$(MAKE) --no-print-directory prod-status

prod-status: ## Color activo, contenedores y verificación pública
	@ssh $(SERVER) 'cd $(DEPLOY_PATH) && echo "color activo: $$(cat .bluegreen/active 2>/dev/null)" && docker ps --filter name=elecciones --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
	@curl -sI --max-time 10 https://elecciones.orgullorojo.com/ | grep -iE "^(HTTP|x-served-by)"

prod-logs: ## Logs del color activo (contenedor) y de nginx del host
	ssh $(SERVER) 'cd $(DEPLOY_PATH) && c=$$(cat .bluegreen/active) && docker logs --tail 100 elecciones-$$c-web-1; echo "--- nginx host ---"; sudo tail -n 50 /var/log/nginx/elecciones.access.log'

ssh-vps: ## Conecta al VPS
	ssh $(SERVER)

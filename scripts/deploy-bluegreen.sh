#!/usr/bin/env bash
# Deploy blue/green sin caída (EN el VPS, desde ~/projects/elecciones): construye el color INACTIVO con <ref>,
# smoke directo, y conmuta. Si algo falla antes de conmutar, el tráfico nunca se movió.
#   scripts/deploy-bluegreen.sh <ref> [--first]   (--first: primer deploy; sin color activo todavía)
# Variables: SKIP_PUBLIC=1 omite el smoke público (solo antes de instalar el TLS).
set -uo pipefail
REF="${1:?Uso: $0 <tag|commit> [--first]}"; FIRST="${2:-}"
cd "$(dirname "$0")/.." || exit 1
. scripts/lib-bluegreen.sh
init_state
old="$(active_color)"
if [ -z "$old" ] && [ "$FIRST" != "--first" ]; then log "Sin color activo: es el primer deploy, usar --first"; exit 1; fi
new="$(other_color "${old:-green}")"
export APP_VERSION="$REF"
log "Deploy $REF: activo=${old:-ninguno} -> se construye $new (puerto $(port_of "$new"))"
dc "$new" up -d --build --force-recreate || { log "up falló: producción no se tocó"; exit 1; }
if ! smoke_color "$new"; then
  log "Smoke falló: NO se conmuta; producción sigue en ${old:-ninguno}"; dc "$new" logs --tail 30 web | sed 's/^/    /'; exit 1
fi
if [ -z "$old" ]; then
  # Primer deploy: no hay color previo que revertir; se instala el include y se activa.
  render_conf "$new" > "$BG_STATE_DIR/active.conf.new" && sudo cp "$BG_STATE_DIR/active.conf.new" "$NGINX_ACTIVE_CONF" && sudo nginx -t && sudo nginx -s reload || exit 1
  smoke_public "$new" || { log "Smoke público falló (¿vhost/TLS instalados? ver docs/produccion.md)"; exit 1; }
  echo "$new" > "$BG_STATE_DIR/active"; log "Primer deploy completado: activo=$new"; exit 0
fi
scripts/switch-color.sh "$new" || { log "Conmutación falló; el tráfico sigue/volvió a $old"; exit 1; }
docker image prune -f >/dev/null
log "Deploy $REF completado: activo=$new. Rollback: make rollback (vuelve a $old, que sigue arriba)"

#!/usr/bin/env bash
# Conmuta el tráfico al color indicado (nginx -t + reload graceful). También es el rollback:
# `scripts/switch-color.sh <color-anterior>` (el color viejo sigue arriba). Se corre en el VPS.
set -uo pipefail
TO="${1:?Uso: $0 <blue|green>}"
cd "$(dirname "$0")/.." || exit 1
. scripts/lib-bluegreen.sh
valid_color "$TO" || { echo "Color inválido: $TO" >&2; exit 1; }
init_state
FROM="$(active_color)"
[ "$FROM" = "$TO" ] && { log "$TO ya es el activo"; exit 0; }
smoke_color "$TO" || { log "$TO no pasa el smoke directo: NO se conmuta (tráfico sigue en ${FROM:-?})"; exit 1; }
apply() { render_conf "$1" > "$BG_STATE_DIR/active.conf.new" && sudo cp "$BG_STATE_DIR/active.conf.new" "$NGINX_ACTIVE_CONF" && sudo nginx -t 2>/dev/null && sudo nginx -s reload; }
if ! apply "$TO"; then
  log "Falló nginx -t/reload: restauro el color anterior"; valid_color "$FROM" && apply "$FROM"; exit 1
fi
if ! smoke_public "$TO"; then
  log "La ruta pública no sirve $TO"
  if valid_color "$FROM"; then log "REVIRTIENDO a $FROM"; apply "$FROM"; fi
  exit 1
fi
echo "$TO" > "$BG_STATE_DIR/active"
log "Tráfico conmutado: ${FROM:-ninguno} -> $TO"

#!/usr/bin/env bash
# Funciones comunes de blue/green. Se corre EN el VPS desde ~/projects/elecciones.
BG_STATE_DIR="${BG_STATE_DIR:-.bluegreen}"
DOMAIN="${DOMAIN:-elecciones.orgullorojo.com}"
NGINX_ACTIVE_CONF="${NGINX_ACTIVE_CONF:-/etc/nginx/conf.d/elecciones-active-color.conf}"
log() { echo "[$(date -u +%FT%TZ)] $*"; }
valid_color() { [ "$1" = blue ] || [ "$1" = green ]; }
port_of() { [ "$1" = blue ] && echo 3040 || echo 3140; }
other_color() { [ "$1" = blue ] && echo green || echo blue; }
init_state() { mkdir -p "$BG_STATE_DIR"; }
active_color() { cat "$BG_STATE_DIR/active" 2>/dev/null || true; }
dc() { local c="$1"; shift; COLOR="$c" PORT="$(port_of "$c")" docker compose -p "elecciones-$c" -f docker-compose.bluegreen.yml "$@"; }
render_conf() { printf '# Generado por scripts/switch-color.sh (color activo: %s). No editar a mano.\nupstream elecciones_front { server 127.0.0.1:%s; }\n' "$1" "$(port_of "$1")"; }
# Smoke directo al contenedor del color: health, HTML con el título y cabecera del color correcto.
smoke_color() {
  local c="$1" p; p="$(port_of "$c")"
  for _ in $(seq 1 20); do curl -fs --max-time 3 "http://127.0.0.1:$p/healthz" >/dev/null && break; sleep 2; done
  curl -fs --max-time 5 "http://127.0.0.1:$p/healthz" >/dev/null || return 1
  # Se captura la salida antes de grep: con pipefail, `curl | grep -q` falla (curl 23) en HTML grandes.
  local body hdr
  body="$(curl -fs --max-time 10 "http://127.0.0.1:$p/")" || return 1
  grep -q "<title>" <<<"$body" || return 1
  hdr="$(curl -fsI --max-time 5 "http://127.0.0.1:$p/")" || return 1
  grep -qi "x-served-by: elecciones-$c" <<<"$hdr"
}
# Smoke por la ruta pública (nginx del host + TLS) y comprueba que sirve el color esperado. SKIP_PUBLIC=1 la omite (primer deploy sin TLS).
smoke_public() {
  [ "${SKIP_PUBLIC:-0}" = 1 ] && return 0
  local hdr; hdr="$(curl -fsI --max-time 10 --resolve "$DOMAIN:443:127.0.0.1" "https://$DOMAIN/")" || return 1
  grep -qi "x-served-by: elecciones-$1" <<<"$hdr"
}

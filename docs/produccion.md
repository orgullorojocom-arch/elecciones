# Producción

- **URL:** https://elecciones.orgullorojo.com — DNS ya apunta al VPS (148.113.207.54).
- **Estado verificado (2026-11-12, solo lectura):** DNS OK; el VPS **no tiene todavía** vhost, certificado, carpeta `~/projects/elecciones` ni contenedores `elecciones-*`; puertos 3040/3140 libres; `sudo` sin contraseña disponible para `ubuntu`; `/etc/nginx/conf.d/` se incluye en `http` (lo usan Parkium y Números Rojos).
- **Nada de esto se probó en el VPS**: scripts probados solo en local (`make test`). El primer deploy es el primer uso real de `scripts/*.sh` con nginx del host.

- **Estado (2026-11-12): EN PRODUCCIÓN.** vps-setup, certbot (vence 2027-02-10, renovación automática) y primer deploy hechos; deploy rutinario y rollback verificados (activo: green). Hallazgos del primer uso: `curl|grep -q` con pipefail fallaba con el HTML de 1 MB y el smoke público necesita reintentos tras el reload (ya corregido en `scripts/lib-bluegreen.sh`). `deploy/nginx/*.conf` es el vhost final con los bloques de certbot.

## Primera vez (ingeniero, autónomo) — ya hecho
1. `make vps-setup` (clona el repo en el VPS, instala include de nginx apuntando a green y el vhost; hace `nginx -t`). No recarga nginx.
2. `sudo systemctl reload nginx` en el VPS; luego `sudo certbot --nginx -d elecciones.orgullorojo.com` (agrega 443 y redirect; certbot ya corre en el VPS para otros dominios). Si falla, ver que el DNS resuelva y el puerto 80 llegue.
3. `make deploy FIRST=1` (el primer color es blue).
4. Verificar: `make prod-status`, `curl -sI https://elecciones.orgullorojo.com/` → 200 y `X-Served-By: elecciones-blue`.
5. Copiar el vhost final (con bloques de certbot) a `deploy/nginx/` y commitear.
Si certbot aún no corrió: `SKIP_PUBLIC=1 make deploy FIRST=1` y repetir sin la variable después.

## Deploy rutinario
`make deploy`. Si falla antes de conmutar, producción no se tocó. Si falla la verificación pública, `switch-color.sh` revierte solo.
## Rollback
`make rollback`. Si el color viejo no estuviera arriba: `ssh` al VPS y `scripts/deploy-bluegreen.sh <tag-anterior>`.
## Backups
No aplica (sin BBDD ni estado). La fuente de verdad es el repo en GitHub y los tags `deploy-*`.
## Observabilidad
Logs de acceso/errores de nginx por vhost, logs del contenedor (`docker logs`), `/healthz`, cabecera `X-Served-By`. La oficina chequea la URL pública y el origen (ver config del proyecto).
## Requiere al CEO
Nada: el VPS ya puede clonar el repo (verificado). Solo si el tercero lo vuelve privado sin acceso, pedir una deploy key.

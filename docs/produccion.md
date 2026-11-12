# Producción

- **URL:** https://elecciones.orgullorojo.com — DNS ya apunta al VPS (148.113.207.54).
- **Estado verificado (2026-11-12, solo lectura):** DNS OK; el VPS **no tiene todavía** vhost, certificado, carpeta `~/projects/elecciones` ni contenedores `elecciones-*`; puertos 3040/3140 libres; `sudo` sin contraseña disponible para `ubuntu`; `/etc/nginx/conf.d/` se incluye en `http` (lo usan Parkium y Números Rojos).
- **Nada de esto se probó en el VPS**: scripts probados solo en local (`make test`). El primer deploy es el primer uso real de `scripts/*.sh` con nginx del host.

## Primera vez (ingeniero, autónomo)
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
Nada, salvo que `orgullorojocom-arch/elecciones` no sea clonable desde el VPS (necesita deploy key de solo lectura en GitHub: si `vps-setup` falla en el clone, pedirla).

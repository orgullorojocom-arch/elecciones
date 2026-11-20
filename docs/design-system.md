# Design system — Elecciones Independiente 2026

Extraído el 2026-11-20 de `index.html` (producción = repo, 988.827 bytes) por Diseño UX/UI. Tarea #461.

> **Alcance.** El contenido y el frontend los desarrolla un tercero (Hernán / OrgulloRojo) y la compañía solo hace de hosting: **no se modifica `index.html`**. Este documento describe lo que existe (no inventa nada) y sirve para (1) auditar, (2) pasarle hallazgos al tercero y (3) verificar el sitio tras cada publicación. No hay React ni Tailwind: es HTML + CSS + JS embebidos, sin build.

## 1. Principios del sitio (lo que se ve)

- Tema **oscuro único** (`color-scheme: dark`), "noche de tribuna": fondo casi negro, rojo de marca, grilla fina de cancha, titulares enormes en mayúsculas con grano.
- Una sola columna editorial, organizada en **capítulos numerados** (.01 Candidatos, .02 Lo que dijeron, .03 Cómo votar, .04 Fechas, .05 Propuestas).
- Mobile-first en la práctica: cada bloque colapsa a 1 columna bajo 760–1060 px.
- Español rioplatense, voseo ("Fijate", "Tildá", "Chequeá"), tono hincha, directo.

## 2. Tokens

Definidos en `:root` de `index.html` (no hay `tailwind.config`).

### Color

| Token | Valor | Uso |
|---|---|---|
| `--ink` | `#0B0909` | Fondo de página |
| `--ink-2` | `#141010` | Superficies (tarjetas, paneles, celdas) |
| `--ink-3` | `#1C1514` | Superficie alterna (filas pares, barra de progreso) |
| `--paper` | `#ECEAE7` | Texto principal y títulos |
| `--muted` | `#A99F9C` | Texto secundario (7,3:1 sobre `--ink-2`) |
| `--dim` | `#6F6563` | Texto terciario, notas, estados "a confirmar" (**3,2–3,5:1: no cumple AA**, ver H3) |
| `--red` | `#E3060B` | Rojo de texto, acentos, iconos, foco (4,06:1 sobre `--ink`) |
| `--brand` | `#AB100F` | Rojo de marca: rellenos, textura `.tex`, hover de botones |
| `--line` | `rgba(236,234,231,.10)` | Divisores sutiles |
| `--line-2` | `rgba(236,234,231,.18)` | Bordes de controles (≈1,6:1: no cumple 3:1 para controles, ver H4) |
| (suelto) `#D5D0CD` | — | Cuerpo de texto en tarjetas (12,4:1). No es token: aparece ~8 veces en literal |
| (suelto) `#241A18` | — | Hover de fila de tabla |

Combinaciones verificadas: `--paper` sobre `--brand` 6,2:1 ✔ · `--brand` sobre `--paper` 6,2:1 ✔ · `--paper` sobre `--ink` 16,5:1 ✔.

### Tipografía

Todas embebidas en base64 (`font-display: swap`).

| Token | Familia | Uso |
|---|---|---|
| `--display` | "DGE ExBold" (fallback Oswald, Impact) | Titulares, cifras grandes, nombres. Siempre `800`, `text-transform: uppercase`, `line-height` .8–.9 |
| `--accent` | "DGE LightItalic" | Segunda línea itálica de h1/h2 (`.it`) |
| `--tag` | "DGE Regular" | Etiquetas de lista (`.tag`), "Estás listo para votar" |
| `--label` | "Sinter" (fallback Roboto OR) | Etiquetas en mayúsculas con `letter-spacing` .14–.3em (`.label`) |
| `--body` | "Roboto OR" (fallback Helvetica Neue, Arial) | Texto corrido, peso 300 base |

Escala usada (px): cuerpo 17 (peso 300, interlineado 1,6) · lede 18 · texto de tarjeta 15,5 · secundario 13,5–14,5 · notas 12–13 · labels 9,5–12 · displays 34, 38, 44, 50, 52, 54, 62, 64–76, 96, 104, 150. h1 `clamp(70px,25vw,250px)`, h2 `clamp(56px,8.4vw,116px)`. No hay escala modular: cada componente fija su tamaño.

Efectos: `.grain` (texto con textura de grano vía `background-clip:text`, color `transparent`), `.tex` (fondo rojo con textura de marca). Sinter no trae tildes ni Ñ: el JS las dibuja aparte (`.ac`) y deja el texto real en `.sr` para lectores de pantalla.

### Espaciado

Sin escala formal; valores recurrentes: 4 · 6 · 8 · 10 · 12 · 14 · 16 · 20 · 24 · 28 · 30 · 36 · 44 · 56 · 72 · 104. Contenedor `.wrap`: `max-width:1240px`, padding lateral 20 px (16 px ≤600) respetando `safe-area-inset`. Capítulos: `padding-block:104px 40px` (72/24 en móvil). Grillas con `gap` 20 px entre tarjetas, 8 px entre chips y tabs.

### Forma y elevación

- **Radios: ninguno** (esquinas rectas) en toda la UI. Excepciones: círculo en avatares de pestañas (`50%`) y en el punto "en vivo"; `rx` 3–7 dentro de las ilustraciones SVG de DNI y carnet.
- Bordes de 1 px (`--line` / `--line-2`) en vez de sombras. Sombra solo en `.pbtn` (halo rojo) y el pulso del punto en vivo.
- Header pegajoso con `backdrop-filter: blur(12px)` sobre `rgba(11,9,9,.82)`.

### Breakpoints

`1180` (nav compacta) · `1100` (oculta subtítulo de marca) · `1060` (candidatos a 1 columna) · `1000` (requisitos a 2 col.) · `900` (oculta nav, grillas a 1 col.) · `860` · `800` (tabla con columna fija) · `760` · `640` · `600` · `520` · `480` · `420`.

### Movimiento

`@media (prefers-reduced-motion: reduce)` desactiva animaciones y transiciones y el scroll suave ✔. Transiciones de 150–300 ms en hover/estado.

## 3. Componentes y variantes

| Componente | Clase | Variantes / estados |
|---|---|---|
| Header | `.top` | Sticky; la nav (`.nav`) se oculta ≤900 px; el CTA cambia texto largo (`.l`) por corto (`.s`) ≤480 px |
| Botón secundario / CTA | `.cta` | `.tex` (relleno rojo), `.ghost` (borde, hover borde claro) |
| Botón principal | `.pbtn` | por defecto (relleno `.tex`, halo, hover sube 2 px), `.lite` (papel con texto rojo) |
| Enlace en línea | `.inline-link` | Subrayado rojo, hover rojo |
| Aviso en vivo | `.live` | Punto pulsante (se detiene con reduced-motion), `role="note"` |
| Kicker + capítulo | `.kicker`, `.chap-head`, `.num` | Número gigante `.0X` + título h2 + `lede` |
| Cuenta regresiva | `.count` | Primer cubo `.tex`, resto `--ink-2`; 3 estados por JS: faltan / hoy se vota / terminó |
| Cifra | `.fact` | Número `.grain` + descripción |
| Tarjeta de candidato | `.cand` | Foto, nombre, listas (`.tag`), bloques `.blk` (fórmula `dl.roles`, equipo, puntos `ul.pts`), redes `.soc` (`.off` = sin cuenta, borde punteado). `.tbc` = "A confirmar" |
| Tabla cara a cara | `table.vs` | Encabezado rojo por candidato, `.who` (nombre en chip), `.yes` (tilde), `.no` (sin dato, punteado). ≤800 px: scroll horizontal + columna de temas fija + aviso "Deslizá…" |
| Pestañas "Lo que dijeron" | `.dj-tabs` / `.dj-tab` | Inactiva (foto en gris), seleccionada `aria-selected="true"` (relleno `.tex`) |
| Acordeón de temas | `details.dj-topic` | Abierto/cerrado, icono +/− (`.pm`). El primero abierto |
| Cita con fuente | `.dj-list li` + `.dj-src` | Borde izquierdo rojo, programa · fecha · minuto (enlace si hay URL) |
| Datos de cuándo/dónde | `.when` | 3 celdas con icono; la 3.ª lleva `.cta.ghost.map` |
| Tarjeta "llevá" | `.card` | `.tex` (obligatorio) / `.dark` (recomendado), badge `.must` |
| Requisitos | `.reqgrid` / `.req` | 5 celdas con icono, cifra y texto |
| Banda de padrón | `.pband` | Bloque `.tex` con icono, texto y `.pbtn.lite` |
| Panel con dato | `.panel` | `.bignum`, barra `.bar` (86/14 %, `role="img"` con `aria-label`), grilla de 70 mesas `.grid70` (`aria-hidden`) y leyenda |
| Checklist | `.check` | Casilla personalizada `.box` (input real oculto), progreso `.prog`, mensaje final `.done-msg` (`hidden`). Estado en `localStorage` (`or-elecciones-check`) |
| Línea de tiempo | `ol.tl` | Hito `.done` ("Ya pasó"), `.now` ("Hoy"), "Lo que viene", `.final` (elecciones). Calculado por JS con hora argentina |
| Bloque "próximamente" | `.soon`, `.dj-soon` | Para contenido aún sin cargar |
| Pie | `.foot` | Marca, fuentes (`#sources`), leyenda legal con fecha |
| Iconos | `<symbol id="i-…">` | Sprite SVG inline, trazo 2,2, `currentColor`. ~20 iconos (cal, clock, pin, 18, years, cuota, shield-ok, hash, padron, vs, check, arrow, ig, x, fb, web) |

## 4. Patrones

**Navegación.** Anclas dentro de la página (`#candidatos`, `#cara-a-cara`, `#dijeron`, `#como-votar`, `#fechas`), scroll suave, `scroll-padding-top` solo para safe-area (ver H9). Enlaces externos con `target="_blank" rel="noopener"`.

**Formularios.** No hay formularios. Único control de entrada: la checklist (casillas con `<label for>` correcto, foco visible sobre `.box`, texto táctil ≥ 60 px de alto por fila ✔).

**Estados vacío / carga / error.**
- *Vacío:* `.dj-soon` ("Estamos escuchando sus entrevistas"), `.soon` ("Próximamente"), `.tbc` ("A confirmar"), `.no` (celda sin dato), `.soc.off`. Siempre con texto, nunca una caja en blanco ✔.
- *Carga:* no existe (el contenido es estático y se pinta con JS inline, sin red). El único riesgo es el peso inicial (H8).
- *Error:* no hay llamadas de red; `localStorage` tiene `try/catch` y degrada sin romper ✔. No existe página 404 propia del sitio.

**Tiempo.** Todo con hora de Argentina (`-03:00`). El pie y el aviso "Última actualización" muestran la fecha de carga.

## 5. Reglas de accesibilidad (WCAG 2.2 AA)

Lo que **ya cumple** y hay que conservar: `prefers-reduced-motion`; foco visible `2px solid --red`; `aria-label` en nav, logo y barra de datos; `aria-hidden` en decoración; `role="tablist"`; texto alternativo de fotos de candidato; texto real para lectores de pantalla donde Sinter dibuja tildes; `h1` único y jerarquía h2→h3→h4; `meta viewport` sin bloquear zoom; `safe-area` en iPhone.

Reglas para todo cambio nuevo:
1. Texto normal ≥ 4,5:1; texto grande (≥ 24 px, o ≥ 18,7 px en negrita) ≥ 3:1; bordes de controles e iconos informativos ≥ 3:1.
2. Texto informativo nunca menor a 12 px; las etiquetas decorativas en mayúsculas, 11 px mínimo.
3. Objetivos táctiles ≥ 44×44 px en móvil (mínimo absoluto WCAG 2.2: 24×24).
4. Todo control con nombre accesible y foco visible; nada solo con hover.
5. Un patrón ARIA completo o ninguno (no usar `role="tab"` sin `tabpanel`, `aria-controls` ni teclado).
6. `lang="es"` en `<html>`; ids únicos.
7. El texto con `background-clip:text` debe tener color de respaldo.

## 6. Reglas de copy

- Español rioplatense, voseo y tono hincha: "Fijate", "Tildá", "Chequeá", "Llevalo también".
- Frases cortas; la conclusión primero; cifra o fecha concreta ("9 a 18 h", "13 de diciembre", "Av. Mitre 470").
- Palabras clave en `<b>` dentro de textos de apoyo (`.lede b`, `.hero-foot p b`).
- Botones con verbo: "Chequeá si estás en el padrón", "Cómo llegar", "Ir a OrgulloRojo".
- Fechas `DD/MM`; separador de miles con punto (62.566); horas "9 a 18 h".
- Lo no confirmado se dice: "A confirmar", "Próximamente", "Puede cambiar hasta la oficialización".
- Toda declaración de un candidato lleva programa y minuto de la fuente.

## 7. Hallazgos priorizados

Impacto (A/M/B) y esfuerzo (B/M/A). Verificados leyendo el código y la producción; contrastes calculados con la fórmula WCAG 2.2.

| # | Hallazgo | Impacto | Esfuerzo | Prioridad |
|---|---|---|---|---|
| H1 | `<html>` sin `lang`: los lectores de pantalla leen en el idioma del sistema y Chrome ofrece "traducir" una página que ya está en español. Además `id="upd"` está **duplicado** (aviso del hero y pie), así que el JS/enlaces solo alcanzan el primero | Alto | Bajo | **1** |
| H2 | Pestañas "Lo que dijeron" con `role="tab"` incompleto: sin `aria-controls`, sin `role="tabpanel"` en `#dj-body`, sin `tabindex` ni flechas de teclado. Un lector las anuncia como pestañas pero no se comportan como tales | Medio-alto | Bajo | **2** |
| H3 | Texto `--dim` (`#6F6563`) con 3,2–3,5:1 en ~12 usos de 10–13 px (orden alfabético, `.dj-src`, `.n` de temas, leyenda legal, `.soc-note`, `.tbc`, `.dj-tab small`, `.foot-note`, `.swipe`). Además `--red` como texto pequeño sobre `--ink` rinde 4,06:1 (labels de 11–12 px: `.blk h3`, `.kicker`, "El padrón", "Antes de salir") | Alto | Bajo (cambio de 2 tokens) | **3** |
| H4 | Casillas de la checklist, bordes de pestañas inactivas y botón +/− con borde `--line-2` ≈ 1,6:1 (WCAG 1.4.11 pide 3:1). Una casilla vacía casi no se ve en pantallas con poco brillo | Medio | Bajo | **4** |
| H5 | Tamaños de letra de 8,5–10 px (`.soc` 9,5 px, `.dj-tab small` 8,5 px móvil, `.count span` 10 px, `.tl .s` 10 px, `dl.roles dt` 10 px, `th` de tabla 9,5 px). Ilegibles con luz de estadio/celular y bajo el piso de la regla 2 | Medio | Bajo | **5** |
| H6 | Peso de la primera visita: ~690 KB gzip (989 KB crudos; fuentes e imágenes en base64 dentro del HTML). Con `Cache-Control: no-cache` + ETag las visitas repetidas revalidan (304) pero **cada publicación obliga a bajar todo de nuevo**, y un cambio de una línea invalida fuentes e imágenes. En datos móviles el día de la elección es lo que más se nota | Medio | Medio (contenido: sacar fuentes/imágenes a archivos cacheables, lo decide el tercero) | **6** |
| H7 | Titulares y números con `color: transparent` + `background-clip: text` (`.grain`): sin respaldo en modo alto contraste, impresión o navegadores sin soporte → texto invisible | Medio | Bajo | 7 |
| H8 | Dos duplicidades de tokens: colores literales fuera de `:root` (`#D5D0CD` ×8, `#241A18`, `#6b4442`, `rgba(171,16,15,…)`) y tamaños sueltos sin escala (≥ 25 valores de `font-size`). No rompe nada hoy; encarece cualquier cambio de marca | Bajo | Medio | 8 |
| H9 | `scroll-padding-top` solo cubre safe-area: al saltar a un capítulo desde la nav, el header sticky de 72 px tapa el comienzo del título | Medio | Bajo | **4** |
| H10 | Enlaces con `target="_blank"` sin aviso de "se abre en pestaña nueva" (solo 1 de ~25 lo indica) | Bajo | Bajo | 9 |
| H11 | Hover de fila de tabla y de `.soc` sin equivalente de foco de teclado en el contenedor (los enlaces sí tienen foco global) | Bajo | Bajo | 10 |

Lo que **no** es un problema (verificado): contraste de `--paper`/`--muted` sobre fondos; foco visible; `prefers-reduced-motion`; zoom; checklist con `label` real; barra de datos con `aria-label`; desbordes horizontales (tabla con scroll propio y aviso).

## 8. Cómo se entregan los hallazgos

Como `index.html` es del tercero, los arreglos los implementa Hernán; Ingeniería los empaqueta, se los envía por el hilo de correo y **verifica en producción** tras cada publicación. Las tareas (cargadas en la oficina) llevan los criterios de aceptación visuales/verificables. H6 solo se resuelve separando fuentes e imágenes del HTML (decisión del tercero); el hosting no puede hacerlo sin tocar `index.html`.

## 9. Cómo verificar (checklist rápido tras cada publicación)

```bash
curl -s https://elecciones.orgullorojo.com | grep -o '<html[^>]*>'          # debe incluir lang="es"
curl -s https://elecciones.orgullorojo.com | grep -o 'id="upd"' | wc -l     # debe dar 1
curl -sI -H 'Accept-Encoding: gzip' https://elecciones.orgullorojo.com | grep -i 'cache-control\|etag\|content-encoding'   # hoy: no-cache + ETag + gzip
```
Revisión visual a 360, 768 y 1280 px; Tab recorriendo toda la página; lector de pantalla (VoiceOver o NVDA) en las pestañas y en la checklist.

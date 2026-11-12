FROM nginx:1.27-alpine
COPY docker/nginx.conf /etc/nginx/templates/default.conf.template
COPY index.html /usr/share/nginx/html/index.html
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}
RUN echo "${APP_VERSION}" > /usr/share/nginx/html/version.txt
HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD wget -qO- http://127.0.0.1/healthz >/dev/null || exit 1

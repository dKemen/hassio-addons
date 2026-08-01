# Both ARGs have to be declared before the first FROM: only the global ARG
# scope is visible to FROM instructions.
#
# The upstream backend image is the base on purpose: the server runs straight
# from TypeScript via tsx against node_modules that were built for Node 24 on
# musl. Swapping in a different base would risk native-module ABI mismatches.
ARG BUILD_FROM=codewithcj/sparkyfitness_server:v1.6.0
ARG SPARKYFITNESS_FRONTEND=codewithcj/sparkyfitness:v1.6.0

# The frontend stage only supplies the pre-built static assets, the nginx
# template and the upstream entrypoint that renders it.
# hadolint ignore=DL3006
FROM ${SPARKYFITNESS_FRONTEND} AS frontend

# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# The base image is Alpine based and has no bash, so use ash for build steps.
SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# bash        - required by bashio and by the upstream frontend entrypoint
# gettext     - envsubst, used to render the nginx template
# jq          - required by bashio
# nginx       - serves the frontend and proxies /api to the backend
# openssl     - generates the persisted secrets on first start
# postgresql18 - bundled database server; the base image already ships the
#                matching postgresql18-client
# su-exec     - drops privileges to the postgres user
# xz          - needed to unpack the s6-overlay release tarballs
RUN apk add --no-cache \
        bash \
        gettext \
        jq \
        nginx \
        openssl \
        postgresql18 \
        su-exec \
        tzdata \
        xz

ARG S6_OVERLAY_VERSION=3.2.3.2
# uname -m yields exactly the architecture names used by the s6-overlay
# assets (x86_64, aarch64), and the add-on is built on the target machine.
RUN set -eu; \
    arch="$(uname -m)"; \
    curl -fsSL -o /tmp/s6-noarch.tar.xz \
        "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz"; \
    curl -fsSL -o /tmp/s6-arch.tar.xz \
        "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${arch}.tar.xz"; \
    tar -C / -Jxpf /tmp/s6-noarch.tar.xz; \
    tar -C / -Jxpf /tmp/s6-arch.tar.xz; \
    rm -f /tmp/s6-noarch.tar.xz /tmp/s6-arch.tar.xz

ARG BASHIO_VERSION=0.18.1
RUN set -eu; \
    mkdir -p /tmp/bashio; \
    curl -fsSL "https://github.com/hassio-addons/bashio/archive/v${BASHIO_VERSION}.tar.gz" \
        | tar -xzf - --strip-components=1 -C /tmp/bashio; \
    mv /tmp/bashio/lib /usr/lib/bashio; \
    ln -s /usr/lib/bashio/bashio /usr/bin/bashio; \
    rm -fr /tmp/bashio

# Static frontend, nginx template and the upstream renderer. Keeping the
# upstream entrypoint instead of re-implementing its nginx config means the
# rate limit zones, MCP streaming and cache headers stay in sync with upstream.
COPY --from=frontend /usr/share/nginx/html /usr/share/nginx/html
COPY --from=frontend /etc/nginx/templates/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=frontend /docker-entrypoint.sh /usr/share/sparkyfitness/frontend-entrypoint.sh

COPY rootfs /

# The chmod on the s6 scripts is deliberate: s6 refuses to run anything that is
# not executable, and this way the build does not depend on the checkout having
# preserved the mode bits.
RUN set -eu; \
    chmod a+x /usr/share/sparkyfitness/frontend-entrypoint.sh; \
    mkdir -p /etc/nginx/conf.d /var/log/nginx /var/run/nginx /var/cache/nginx; \
    rm -f /etc/nginx/http.d/default.conf; \
    chmod 755 /etc/s6-overlay/s6-rc.d/*/run /etc/s6-overlay/s6-rc.d/*/finish

ENV PGDATA=/data/postgresql \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.version="${BUILD_VERSION}"

# s6-overlay supervises postgres, the backend and nginx. The inherited CMD must
# be cleared, otherwise s6 would start the backend a second time.
ENTRYPOINT ["/init"]
CMD []

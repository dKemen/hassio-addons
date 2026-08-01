# The linuxserver image is the maintained multi-arch build of PairDrop; the
# upstream workflow only builds locally as a CI check and publishes nothing.
# It already ships s6-overlay v3 and the PairDrop service, so this add-on only
# has to translate the Home Assistant options into environment variables.
#
# Pulled from ghcr.io rather than lscr.io. Both serve the same image, but
# lscr.io is a redirector that is not reachable from every network, and a
# failure there breaks the build before it starts.
ARG BUILD_FROM=ghcr.io/linuxserver/pairdrop:v1.11.2-ls142
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

# jq reads /data/options.json. It is usually present in the base image already;
# installing it explicitly keeps the add-on independent of that.
RUN apk add --no-cache jq

# Untouched copies of the files the branding options rewrite. run.sh restores
# from these on every start, so repeated restarts cannot stack edits.
RUN set -eu; \
    mkdir -p /opt/pairdrop-pristine/styles; \
    cd /app/pairdrop/public; \
    cp index.html manifest.json service-worker.js /opt/pairdrop-pristine/; \
    cp styles/styles-main.css /opt/pairdrop-pristine/styles/; \
    cp -r lang /opt/pairdrop-pristine/lang

COPY run.sh /run.sh
RUN chmod 755 /run.sh

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

# run.sh exports the configuration and then hands over to the base image's
# s6-overlay init, so s6 still ends up as PID 1. The inherited CMD must be
# cleared so s6 does not additionally run it as a service.
ENTRYPOINT ["/run.sh"]
CMD []

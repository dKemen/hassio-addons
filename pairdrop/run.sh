#!/usr/bin/env bash
# ==============================================================================
# Home Assistant Add-on: PairDrop
#
# Translates the add-on options into the environment variables PairDrop reads,
# then hands over to the base image's s6-overlay init.
#
# The options are read straight from /data/options.json rather than through
# bashio: PairDrop needs no Supervisor data, and this keeps the startup free of
# an API round trip and of a bashio install.
# ==============================================================================
set -euo pipefail

readonly OPTIONS_FILE="/data/options.json"
readonly PUBLIC_DIR="/app/pairdrop/public"
readonly PRISTINE_DIR="/opt/pairdrop-pristine"

# Prints the option as a string, or nothing when it is absent or null.
# Booleans come out as "true"/"false" and integers as digits, which is exactly
# what PairDrop expects.
option() {
    if [ ! -f "${OPTIONS_FILE}" ]; then
        return 0
    fi
    jq -r --arg key "${1}" \
        'if has($key) and .[$key] != null then (.[$key] | tostring) else empty end' \
        "${OPTIONS_FILE}"
}

# Only exported when the user set a value, so PairDrop keeps its own default.
export_if_set() {
    local value
    value="$(option "${2}")"
    if [ -n "${value}" ]; then
        export "${1}=${value}"
        echo "[pairdrop-addon] ${1}=${value}"
    fi
}

# PairDrop has no setting for either of these, so the add-on rewrites the
# static files it serves. Always starting from the pristine copies keeps this
# idempotent: a restart re-applies the current options instead of stacking
# another edit on top of the previous one.
apply_branding() {
    local name colour escaped cache_suffix

    cp "${PRISTINE_DIR}/index.html" "${PUBLIC_DIR}/index.html"
    cp "${PRISTINE_DIR}/manifest.json" "${PUBLIC_DIR}/manifest.json"
    cp "${PRISTINE_DIR}/service-worker.js" "${PUBLIC_DIR}/service-worker.js"
    cp "${PRISTINE_DIR}/styles/styles-main.css" "${PUBLIC_DIR}/styles/styles-main.css"

    name="$(option instance_name)"
    colour="$(option primary_color)"

    if [ -z "${name}" ] && [ -z "${colour}" ]; then
        return 0
    fi

    if [ -n "${name}" ]; then
        # The name lands in HTML attributes and in element text, and then in a
        # sed replacement, so escape for both.
        escaped="$(printf '%s' "${name}" \
            | sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' -e 's/"/\&quot;/g' \
            | sed -e 's/[\\&|]/\\&/g')"
        sed -i \
            -e "s|<title>[^<]*</title>|<title>${escaped}</title>|" \
            -e "s|\(<meta name=\"application-name\" content=\)\"[^\"]*\"|\1\"${escaped}\"|" \
            -e "s|\(<meta name=\"apple-mobile-web-app-title\" content=\)\"[^\"]*\"|\1\"${escaped}\"|" \
            -e "s|\(<meta property=\"og:title\" content=\)\"[^\"]*\"|\1\"${escaped}\"|" \
            -e "s|<h1>PairDrop</h1>|<h1>${escaped}</h1>|" \
            "${PUBLIC_DIR}/index.html"

        # name and short_name drive the label when the app is installed to a
        # home screen.
        jq --arg name "${name}" '.name = $name | .short_name = $name' \
            "${PUBLIC_DIR}/manifest.json" > "${PUBLIC_DIR}/manifest.json.tmp" \
            && mv "${PUBLIC_DIR}/manifest.json.tmp" "${PUBLIC_DIR}/manifest.json"

        echo "[pairdrop-addon] instance name: ${name}"
    fi

    if [ -n "${colour}" ]; then
        # --primary-color is declared on the body selector, so an equally
        # specific rule at the end of the file wins. --accent-color is defined
        # as var(--primary-color) and follows automatically, and neither theme
        # block redefines it.
        printf '\n/* Home Assistant add-on option */\nbody { --primary-color: %s; }\n' \
            "${colour}" >> "${PUBLIC_DIR}/styles/styles-main.css"

        jq --arg colour "${colour}" '.theme_color = $colour' \
            "${PUBLIC_DIR}/manifest.json" > "${PUBLIC_DIR}/manifest.json.tmp" \
            && mv "${PUBLIC_DIR}/manifest.json.tmp" "${PUBLIC_DIR}/manifest.json"

        echo "[pairdrop-addon] primary colour: ${colour}"
    fi

    # The service worker caches index.html, the stylesheet and the manifest,
    # and drops every cache whose name no longer matches. Folding the settings
    # into the cache version means changing an option invalidates the old copy
    # instead of serving it until the next PairDrop release.
    cache_suffix="$(printf '%s|%s' "${name}" "${colour}" | md5sum | cut -c1-8)"
    sed -i \
        "s|^const cacheVersion = '\(.*\)';|const cacheVersion = '\1-${cache_suffix}';|" \
        "${PUBLIC_DIR}/service-worker.js"
}

if [ ! -f "${OPTIONS_FILE}" ]; then
    echo "[pairdrop-addon] No ${OPTIONS_FILE}; starting with the image defaults"
else
    # PairDrop compares these against the literal string "true", so passing
    # "false" reliably disables them.
    export_if_set RATE_LIMIT rate_limit
    export_if_set WS_FALLBACK ws_fallback
    export_if_set DEBUG_MODE debug_mode
    export_if_set IPV6_LOCALIZE ipv6_localize
    export_if_set SIGNALING_SERVER signaling_server
    export_if_set TZ timezone

    apply_branding
fi

exec /init

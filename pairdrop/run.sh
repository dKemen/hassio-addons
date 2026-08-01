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
fi

exec /init

#!/bin/bash
set -e

OPTIONS_FILE="/data/options.json"

if [ -f "$OPTIONS_FILE" ]; then
    TOKEN="$(node -e 'try{const fs=require("fs");const o=JSON.parse(fs.readFileSync("/data/options.json","utf8"));process.stdout.write(o.adoption_token||"")}catch(e){}')"
    if [ -n "$TOKEN" ]; then
        export GP_ADOPTION_TOKEN="$TOKEN"
        echo "[hassio-addon] Using configured adoption_token; probe will auto-adopt"
    else
        echo "[hassio-addon] No adoption_token configured; falling back to adoption-code flow"
    fi
fi

exec /bin/bash /entrypoint.sh

#!/bin/bash

set -euo pipefail

USER_STEAMID="$1"
ASSETS_DIR="./assets"
STEAM_GRID_PATH="${HOME}/.var/app/com.valvesoftware.Steam/.local/share/Steam/userdata/${USER_STEAMID}/config/grid"

if [ -z "$USER_STEAMID" ]; then
    echo "Usage: $0 <steamid>"
    exit 1
fi

if ! [[ "$USER_STEAMID" =~ ^[0-9]+$ ]]; then
    echo "Error: Steam ID must be a number." >&2
    exit 1
fi

if [ ! -d "${ASSETS_DIR}" ]; then
    echo "Error: Assets folder \"${ASSETS_DIR}\" does not exist." >&2
    exit 1
fi

for app_id_dir in "${ASSETS_DIR}"/*; do
    if [ -d "${app_id_dir}" ]; then
        app_id=$(basename "${app_id_dir}")

        if [ -f "${STEAM_GRID_PATH}/${app_id}.json" ]; then
            mkdir -p "${ASSETS_DIR}/${app_id}/logos"
            cp "${STEAM_GRID_PATH}/${app_id}.json" ${ASSETS_DIR}/${app_id}/logos/settings.json
        fi
    fi
done

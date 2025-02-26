#!/bin/bash

set -euo pipefail

USER_STEAMID="$1"
ASSETS_DIR="./assets"
STEAM_GRID_PATH="${HOME}/.var/app/com.valvesoftware.Steam/.local/share/Steam/userdata/${USER_STEAMID}/config/grid"
STEAM_CACHE_PATH="${HOME}/.var/app/com.valvesoftware.Steam/.local/share/Steam/appcache/librarycache"

declare -A asset_types=(
    ["header"]=""
    ["capsule"]="p"
    ["hero"]="_hero"
    ["logo"]="_logo"
)

if [ -z "$USER_STEAMID" ]; then
    echo "Usage: $0 <steamid>"
    exit 1
fi

if ! [[ "$USER_STEAMID" =~ ^[0-9]+$ ]]; then
    echo "Error: Steam ID must be a number." >&2
    exit 1
fi

if ! command -v magick &> /dev/null; then
    echo "Error: ImageMagick is required but not installed. Install it and try again." >&2
    exit 1
fi

if [ ! -d "${ASSETS_DIR}" ]; then
    echo "Error: Assets folder \"${ASSETS_DIR}\" does not exist." >&2
    exit 1
fi

if [ ! -d "${STEAM_GRID_PATH}" ]; then
    echo "Error: Steam grid folder \"${STEAM_GRID_PATH}\" does not exist." >&2
    exit 1
fi

if [ ! -d "${STEAM_CACHE_PATH}" ]; then
    echo "Error: Steam cache directory \"${STEAM_CACHE_PATH}\" does not exist." >&2
    exit 1
fi

for app_id_dir in "${ASSETS_DIR}"/*; do
    if [ -d "${app_id_dir}" ]; then
        app_id=$(basename "${app_id_dir}")

        for type in "${!asset_types[@]}"; do
            asset_file="${app_id_dir}/${type}.png"
            if [ -f "${asset_file}" ]; then
                target="${STEAM_GRID_PATH}/${app_id}${asset_types[$type]}.png"
                if [ ! -f "$target" ]; then
                    cp "${asset_file}" "$target"
                fi
            fi
        done

        settings_file="${app_id_dir}/logos/settings.json"
        if [ -f "${settings_file}" ]; then
            cp ${settings_file} "${STEAM_GRID_PATH}/${app_id}.json"
        fi

        icon="${app_id_dir}/icon.png"
        if [ -f "${icon}" ]; then
            converted_icon="${app_id_dir}/.icon.jpg"
            if [ ! -f "$converted_icon" ]; then
                magick "${icon}" -resize 32x32 "$converted_icon"
            fi

            if [ -d "${STEAM_CACHE_PATH}/${app_id}" ]; then
                cached_icon=$(find "${STEAM_CACHE_PATH}/${app_id}" -type f -name "*.jpg" | grep -E '[a-f0-9]{40}\.jpg' || true)
                if [ -f "${cached_icon}" ]; then
                    if [ ! -f "${cached_icon}.bak" ]; then
                        cp "${cached_icon}" "${cached_icon}.bak"
                    fi
                    cp "${converted_icon}" "${cached_icon}"
                fi

            else
                echo "App ${app_id} does not have a cache directory. Skipping."
            fi
        fi
    fi
done

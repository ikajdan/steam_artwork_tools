#!/bin/bash

set -euo pipefail

ASSETS_DIR="./assets"
FORCE=false
ALLOWED_EXTENSIONS=("jpg" "jpeg" "png" "webp")

declare -A directories=(
    [headers]="header"
    [capsules]="capsule"
    [heroes]="hero"
    [icons]="icon"
    [logos]="logo"
)

while getopts ":f" opt; do
    case $opt in
        f)
            FORCE=true
            ;;
        *)
            echo "Create symlinks for the library assets."
            echo ""
            echo "Usage: $0 [-f]"
            echo "  -f    Force overwrite of existing symlinks."
            exit 1
            ;;
    esac
done

if [ ! -d "${ASSETS_DIR}" ]; then
    echo "Error: Assets folder \"${ASSETS_DIR}\" does not exist." >&2
    exit 1
fi

is_valid_extension() {
    local filename="$1"
    local ext="${filename##*.}"
    for allowed in "${ALLOWED_EXTENSIONS[@]}"; do
        if [[ "$ext" == "$allowed" ]]; then
            return 0
        fi
    done
    return 1
}

for app_id_dir in "${ASSETS_DIR}"/*; do
    if [ -d "${app_id_dir}" ]; then
        app_id=$(basename "${app_id_dir}")

        for dir in "${!directories[@]}"; do
            subfolder="${app_id_dir}/$dir"
            if [ -d "$subfolder" ]; then
                name="${directories[$dir]}"
                symlink_path="${app_id_dir}/${name}.png"
                assets=("$subfolder"/*)

                if [ "${#assets[@]}" -eq 1 ] && [ ! -e "${assets[0]}" ]; then
                    echo "No ${dir} found for app ${app_id}. Skipping." >&2
                    continue
                fi

                valid_assets=()
                for asset in "${assets[@]}"; do
                    if [ -f "$asset" ] && is_valid_extension "$asset"; then
                        valid_assets+=("$asset")
                    fi
                done

                if [ "${#valid_assets[@]}" -eq 0 ]; then
                    continue
                fi

                random_asset="${valid_assets[RANDOM % ${#valid_assets[@]}]}"
                if [ -L "$symlink_path" ]; then
                    if [ "$FORCE" = true ]; then
                        rm "$symlink_path"
                    else
                        continue
                    fi
                fi

                relative_path=$(realpath --relative-to="${app_id_dir}" "${random_asset}")
                ln -s "${relative_path}" "${symlink_path}"
                echo "Symlink created for ${app_id}: ${name}.png -> ${relative_path}"
            fi
        done
    fi
done

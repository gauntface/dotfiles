#!/bin/bash
set -euo pipefail

function update_key() {
    local key=$1
    local file="${DOTFILES_DIR}/data/wallpaper/${key}.txt"
    gsettings set org.gnome.desktop.background "$key" "$(cat "$file")"
}

function setupWallpaper() {
    logTitle "🖥️  Setting up wallpaper..."

    case "${OS}" in
        "Linux - Fedora"*)
            # Get all keys for org.gnome.desktop.background
            keys=$(gsettings list-keys org.gnome.desktop.background)

            # Get and save all wallpaper-related settings
            for key in $keys; do
                update_key "$key"
            done
            ;;
    esac

    logDone
}

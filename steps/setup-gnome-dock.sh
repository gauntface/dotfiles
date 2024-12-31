#!/bin/bash
set -euo pipefail

function setupGnomeDock() {
    logTitle "🖥️  Setting up Gnome dock..."

    case "${OS}" in
        "Linux - Fedora"*)
            # shellcheck disable=SC2046
            dconf write /org/gnome/shell/favorite-apps "$(cat ./data/gnome-dock/favorites.txt)"
            ;;
    esac
    logDone
}


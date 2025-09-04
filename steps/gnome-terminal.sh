#!/bin/bash
set -euo pipefail

function setupGnomeTerminal() {
  logTitle "🖥️  Set up Gnome terminal profiles..."
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"* | "Linux - Fedora"*)
        if [[ ! $(command -v "dconf") ]]; then
            logWarning "dconf command not found - skipping Gnome terminal setup"
            return
        fi

        local profiles_file="${DATA_DIR}/gnome-terminal/profiles.dconf"
        if [[ ! -f "$profiles_file" ]]; then
            logWarning "Gnome terminal profiles file not found: $profiles_file"
            return
        fi
        dconf load /org/gnome/terminal/legacy/profiles:/ < "$profiles_file"
        ;;
  esac
  logDone
}

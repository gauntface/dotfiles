#!/bin/bash
set -euo pipefail

function setupGnomeTerminal() {
  logTitle "🖥️  Sett up Gnome terminal profiles..."
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"* | "Linux - Fedora"*)
        local profiles_file="${DOTFILES_DIR}/gnome-terminal/profiles.dconf"
        if [[ ! -f "$profiles_file" ]]; then
            logWarning "Gnome terminal profiles file not found: $profiles_file"
            return
        fi
        dconf load /org/gnome/terminal/legacy/profiles:/ < "$profiles_file"
        ;;
  esac
  logDone
}

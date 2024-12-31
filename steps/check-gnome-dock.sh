#!/bin/bash
set -euo pipefail

function checkGnomeDock() {
  logTitle "🖥️  Check Gnome dock..."

  case "${OS}" in
    "Linux - Fedora"*)
        fileOld="${DOTFILES_DIR}/data/gnome-dock/favorites.txt"
        fileNew="${DOTFILES_DIR}/data/gnome-dock/favorites.latest.txt"

        touch "$fileNew"

        dconf read /org/gnome/shell/favorite-apps > "$fileNew"
        if diff "$fileOld" "$fileNew" >/dev/null; then
          logStepDone "Dock favorites match"
        else
          logWarning "\t📋  Please compare '${fileOld}' '${fileNew}' for dock favorite differences."
          code --diff "$fileOld" "$fileNew"
          echo "\t⏳  Press enter to continue..."
          read -r
        fi
        ;;
    *)
      logWarning "Unable to handle dependencies for: ${OS}"
      ;;
  esac
  logDone
}

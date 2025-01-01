#!/bin/bash
set -euo pipefail

function check_key() {
    local key=$1
    local fileOld="${DOTFILES_DIR}/data/wallpaper/${key}.txt"
    local fileNew="${DOTFILES_DIR}/data/wallpaper/${key}.latest.txt"

    touch "$fileNew"

    gsettings get org.gnome.desktop.background "$key" > "$fileNew"
    if diff "$fileOld" "$fileNew" >/dev/null; then
      logStepDone "Wallpaper setting ${key} match"
    else
      logWarning "\t📋  Please compare '${fileOld}' '${fileNew}' for wallpaper setting differences."
      code --diff "$fileOld" "$fileNew"
      echo "\t⏳  Press enter to continue..."
      read -r
    fi
}

function checkWallpaper() {
  logTitle "🖥️  Check wallpaper..."

  case "${OS}" in
    "Linux - Fedora"*)
        # Get all keys for org.gnome.desktop.background
        keys=$(gsettings list-keys org.gnome.desktop.background)

        # Get and save all wallpaper-related settings
        for key in $keys; do
            check_key "$key"
        done
        ;;
    *)
      logWarning "Unable to handle wallpaper checks for: ${OS}"
      ;;
  esac
  logDone
}

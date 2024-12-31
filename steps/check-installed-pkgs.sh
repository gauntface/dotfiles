#!/bin/bash
set -euo pipefail

function checkInstalledPackages() {
  logTitle "🖥️  Check installed packages..."

  case "${OS}" in
    "Linux - Fedora"*)
        fileOld="${DOTFILES_DIR}/dependencies/fedora-packages.txt"
        fileQuery="${DOTFILES_DIR}/dependencies/fedora-packages.query.txt"
        fileNew="${DOTFILES_DIR}/dependencies/fedora-packages.latest.txt"

        touch "$fileNew"

        dnf repoquery --userinstalled --qf "%{name} - %{reason}\n" | grep -Ev '^kernel-|^kernel -' > "$fileQuery"
        grep " - User" "$fileQuery" | sed 's/ - User$//' > "$fileNew"

        if diff "$fileOld" "$fileNew" >/dev/null; then
          logStepDone "Installed packages match"
        else
          logWarning "\t📋  Please compare '${fileOld}' '${fileNew}' for package difference."
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

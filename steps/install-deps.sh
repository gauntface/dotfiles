#!/bin/bash
set -euo pipefail

function installDeps() {
    logTitle "📦  Installing dependencies..."

    case "${OS}" in
        "Linux - Ubuntu"* | "Linux - Debian"*)
            # shellcheck disable=SC2046
            sudo apt-get install -y $(cat ./dependencies/linux-packages.txt)
            # shellcheck disable=SC2046
            sudo apt-get install -y $(cat ./dependencies/debian-packages.txt)
            ;;
        "Linux - Fedora"*)
            sudo dnf install -y fedora-workstation-repositories
            sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

            # shellcheck disable=SC2046
            sudo dnf install -y $(cat ./dependencies/linux-packages.txt)
            # shellcheck disable=SC2046
            sudo dnf install -y $(cat ./dependencies/fedora-packages.txt) --skip-unavailable
            ;;
        Darwin*)
            brew bundle install --file ./dependencies/Brewfile
            ;;
    esac
    logDone
}

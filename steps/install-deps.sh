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
            sudo dnf install -y fedora-workstation-repositories dnf-plugins-core
            sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"

            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

            sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

            sudo dnf check-update

            # shellcheck disable=SC2046
            sudo dnf install -y $(cat ./dependencies/linux-packages.txt)
            # shellcheck disable=SC2046
            sudo dnf install -y $(cat ./dependencies/fedora-packages.txt)
            ;;
        Darwin*)
            brew bundle install --file ./dependencies/Brewfile
            ;;
    esac
    logDone
}

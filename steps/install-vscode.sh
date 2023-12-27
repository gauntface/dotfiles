#!/bin/bash
set -euo pipefail

function installVSCode() {
  logTitle "📝  Installing VSCode..."

  case "${OS}" in
		"Linux - Ubuntu"* | "Linux - Debian"*)
			curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
			sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
			rm microsoft.gpg
			if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
				sudo sh -c 'printf "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
			fi
			sudo apt-get update
			sudo apt-get install -y code
			;;
    "Linux - Fedora"*)
			sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
			cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
			sudo dnf check-update
			sudo dnf install -y code
      ;;
  esac
  logDone
}

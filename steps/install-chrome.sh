#!/bin/bash
set -euo pipefail

function installChrome() {
  logTitle "🌎  Installing Chrome..."

  chrome_version="google-chrome-stable"
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
			if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
					sudo apt-get install -y ca-certificates curl gnupg
					sudo mkdir -p /etc/apt/keyrings
					curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-chrome.gpg

					printf "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
			fi
			sudo apt-get update
			sudo apt-get install -y $chrome_version
			;;
    "Linux - Fedora"*)
			sudo dnf config-manager --set-enabled google-chrome
			sudo dnf install -y $chrome_version
			;;
    esac

  logDone
}

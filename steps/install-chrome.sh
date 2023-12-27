#!/bin/bash
set -euo pipefail

function installChrome() {
  logTitle "🌎  Installing Chrome..."

  chrome_version="google-chrome-stable"
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
			if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
					wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
					sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
			fi
			sudo apt-get update
			sudo apt-get install -y $chrome_version
			;;
    "Linux - Fedora"*)
			sudo dnf config-manager --set-enabled google-chrome
			sudo dnf install -y $chrome_version
			;;
    esac

  # Try and open chrome since it may have been installed in the previous step but do not error if it fails
  (google-chrome gauntface.com || true) &> /dev/null &

  echo "\t👷 Please setup Chrome and press enter to continue\n"
  read -r

  logDone
}

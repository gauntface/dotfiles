#!/bin/bash
set -euo pipefail

function installNode() {
  # https://github.com/nodesource/distributions
  logTitle "📦  Installing Node.js..."

  if [[ -x "$(command -v node)" ]]; then
    logDone
    return
  fi

  local node_version
  node_version=$(curl -sL https://nodejs.org/dist/index.json | jq -r '.[0] | .version | split(".") | .[0] | split("v") | .[1]')
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl gnupg
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

        printf "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_%s.x nodistro main" "$node_version" | sudo tee /etc/apt/sources.list.d/nodesource.list

        sudo apt-get update
        sudo apt-get install -y nodejs
        ;;
    "Linux - Fedora"*)
        sudo dnf install -y "https://rpm.nodesource.com/pub_${node_version}.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm"
        sudo dnf install -y --setopt=nodesource-nodejs.module_hotfixes=1 nodejs
        ;;
  esac

  global_dir="${HOME}/.npm-packages"
  echo "\tMaking global directory '${global_dir}'"
  mkdir -p "${global_dir}/lib"

  logDone
}

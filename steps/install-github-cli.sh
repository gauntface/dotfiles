#!/bin/bash
set -euo pipefail

function installGitHubCLI() {
  logTitle "🌎  Installing GitHub CLI..."

  sudo dnf install 'dnf-command(config-manager)'
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh
}

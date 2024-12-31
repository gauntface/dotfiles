#!/bin/bash
set -euo pipefail

function setupDocker() {
  logTitle "🐳  Setting up Docker..."

  sudo systemctl enable --now docker
  # -f here forces success if the group already exists
  sudo groupadd docker -f
  sudo usermod -aG docker "$USER"

  logDone
}

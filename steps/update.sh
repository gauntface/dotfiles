#!/bin/bash
set -euo pipefail

function performUpdate() {
  logTitle "📦  Update system..."

  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          sudo apt-get update -y
          ;;
      "Linux - Fedora"*)
          sudo dnf update -y
          ;;
  esac
  logDone
}

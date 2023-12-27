#!/bin/bash
set -euo pipefail

function setupUdev() {
  logTitle "📝  Setting up udev rules..."
  case "${OS}" in
      Linux*)
          sudo usermod -a -G dialout "$USER"
          sudo cp -R "$DATA_DIR/udev/." "/etc/udev/rules.d/"
          ;;
  esac
  logDone
}

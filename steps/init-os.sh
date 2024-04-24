#!/bin/bash
set -euo pipefail

function initOSVar() {
  OS="$(uname -s)"
  case "${OS}" in
    Linux*)
      OS="${OS} - $(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs)"
      ;;
  esac

  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          ;;
      "Linux - Fedora"*)
          ;;
      Darwin*)
          # NOOP
          ;;
      *)
          echo "\t🤷 Unknown platform '${OS}'"
          exit 1
          ;;
  esac
  export OS
}

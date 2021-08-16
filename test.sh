#!/bin/bash

PLATFORM="$(awk -F= '/^NAME/{print $2}' /etc/os-release)"

case "${PLATFORM}" in
      Ubuntu* | Debian*)
          echo "Hello Ubuntu | Debian"
          ;;
      Fedora*)
          echo "Hello Fedora"
          ;;
      *)
          echo "Running on unknown platform: ${PLATFORM}"
          exit 1
          ;;
  esac
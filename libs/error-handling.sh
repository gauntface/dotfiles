#!/bin/bash
set -euo pipefail

# Catch and log errors
trap 'handle_error $LINENO' ERR
trap 'handle_error $LINENO' EXIT

function handle_error {
  local error_code="$?"
  local error_line="$1"
  local error_command="${BASH_COMMAND}"

  if [[ "${error_code}" != 0 ]]; then
    echo "\n❌  Error occurred on line ${error_line} in command '${error_command}'\n"

    if [[ -e "${ERROR_LOG}" ]]; then
      echo "\t📑  Logs: ${ERROR_LOG}"
    fi

    echo "\t🍀  Good luck debugging.\n"
  fi

  exit $error_code
}

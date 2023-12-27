#!/bin/bash
set -euo pipefail

function optionalStep() {
  local step_title="$1"
  local step_func="$2"

  # Remove the first two arguments
  shift
  shift

  echo "❓ Would you like to ${step_title} (yes/no)?\n"

  while true; do
    read -r response
    case $response in
      [Yy]* )
        echo ""
        "$step_func" "$@"
        break
        ;;
      [Nn]* )
        echo ""
        echo "\t↪️  Skipping step..."
        break
        ;;
      * )
        echo "\tPlease answer 'yes' or 'no'."
        ;;
    esac
  done

  echo ""
}

#!/bin/bash
set -euo pipefail

function initLogging() {
  TEMP_DIR="$(mktemp -d)"
  ERROR_LOG="${TEMP_DIR}/dotfiles-install.log"
  export ERROR_LOG

  touch "$ERROR_LOG"
  exec > "$ERROR_LOG" 2>&1
}

# Disable the -e option for echo
echo() {
  logToUser -e "$@"
}

function echoToLogFile() {
  command echo "$@"
}

function logToUser() {
  # Echo to log file first.
  echoToLogFile "$@"

  enableTTY

  # Echo the provided arguments to the terminal
  command echo "$@"

  disableTTY
}

function enableTTY() {
  # Save the current stdout and stderr file descriptors
  exec 3>&1 4>&2
  # Temporarily redirect stdout and stderr to /dev/tty (terminal)
  exec 1>/dev/tty 2>&1
}

function disableTTY() {
  # Revert the redirection back to the log file
  exec 1>&3 2>&4
  # Close the saved file descriptors
  exec 3>&- 4>&-
}

function logDone() {
  # Add an extra line to the log file
  echoToLogFile ""

  echo "\t✅  Done\n"
}

function logStepDone() {
  echo "✨  " "$@" "\n"
}

function logWarning() {
  echo "\t⚠️  " "$@" "\n"
}

function logTitle() {
  echo "$@"
  echo ""
}

#!/bin/bash
set -euo pipefail

function setupChrome() {
  logTitle "🌎  Setting up Chrome..."

  # Try and open chrome since it may have been installed in the previous step but do not error if it fails
  (google-chrome gauntface.com || true) &> /dev/null &

  echo "\t👷 Please setup Chrome and press enter to continue\n"
  read -r

  logDone
}
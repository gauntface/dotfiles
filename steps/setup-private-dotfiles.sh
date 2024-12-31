#!/bin/bash
set -euo pipefail

function clonePrivateDotfiles() {
  if [[ -d "${PRIV_DOTFILES_DIR}" ]]; then
    return
  fi

  logTitle "📑  Cloning private dotfiles..."

  git clone git@github.com:gauntface/private-dotfiles.git "${PRIV_DOTFILES_DIR}"

  logDone
}

function updatingPrivateDotfiles() {
  logTitle "🔄  Updating private dotfiles..."

  (cd "$PRIV_DOTFILES_DIR" || exit 1; git fetch origin)
  # The pull may error if there are un commited changes
  (cd "$PRIV_DOTFILES_DIR" || exit 1; git pull origin/main || true)

  logDone
}

function runPrivateDotfileSetup() {
  logTitle "️️🖥️  Setting up Private dotfiles..."

  # shellcheck disable=SC1091
  cd "${PRIV_DOTFILES_DIR}"; "./setup.sh"

  logDone
}

function setupPrivateDotfiles() {
  clonePrivateDotfiles

  updatingPrivateDotfiles

  runPrivateDotfileSetup
}

#!/bin/bash
set -euo pipefail

function clonePublicDotfiles() {
  if [[ -d "${DOTFILES_DIR}" ]]; then
    return
  fi

  logTitle "📑  Cloning public dotfiles..."

  git clone git@github.com:gauntface/dotfiles.git "${DOTFILES_DIR}"

  logDone
}

function updatePublicDotfiles() {
  logTitle "🔄  Updating public dotfiles..."

  (cd "$DOTFILES_DIR" || exit 1; git fetch origin)
  # The pull may error if there are un commited changes
  (cd "$DOTFILES_DIR" || exit 1; git pull origin/main || true)

  logDone
}

function setupPublicDotfiles() {
  clonePublicDotfiles

  updatePublicDotfiles
}


#!/bin/bash
set -euo pipefail

function cloneDotfiles() {
  if [[ -d "${DOTFILES_DIR}" ]]; then
    return
  fi

  logTitle "📑  Cloning dotfiles..."

  git clone git@github.com:gauntface/dotfiles.git "${DOTFILES_DIR}"

  logDone
}

function updateDotfiles() {
  logTitle "🔄  Updating dotfiles..."

  (cd "$DOTFILES_DIR" || exit 1; git fetch origin)
  # The pull may error if there are un commited changes
  (cd "$DOTFILES_DIR" || exit 1; git pull origin/main || true)

  logDone
}

function setupDotfiles() {
  cloneDotfiles

  updateDotfiles
}


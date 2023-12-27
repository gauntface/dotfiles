#!/bin/bash
set -euo pipefail

function installOhMyZSH() {
  logTitle "📦  Installing oh-my-zsh..."
  # oh-my-zsh will fail if the oh-my-zsh file already exists
  # This directory should be install on the ZSH var, but that
  # may not be set if the install fails for any reason.
  local zshDefault="${HOME}/.oh-my-zsh"
  local zsh="${ZSH:-$zshDefault}"
  if [[ -d "${zsh}" ]]; then
    logDone
    return
  fi

  curl -sL "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" | zsh -
  logDone
}

function installZSHDraculaTheme() {
  logTitle "📦  Installing Dracula theme for zsh..."
  # Check the ZSH theme is not already installed
  if [[ -d "${HOME}/.custom-zsh/themes/dracula" ]]; then
    logDone
    return
  fi

  git clone https://github.com/dracula/zsh.git "${HOME}/.custom-zsh/themes/dracula"
  ln -s "${HOME}/.custom-zsh/themes/dracula/dracula.zsh-theme" "${HOME}/.custom-zsh/themes/dracula.zsh-theme"
  logDone
}

function setupZSHRC() {
  logTitle "🖥️  Setting up .zshrc..."

  local zshrc_file="${HOME}/.zshrc"

  if [ -L "${zshrc_file}" ] || [ -f "${zshrc_file}" ] ; then
    rm "${zshrc_file}"
  fi

  printf "source  %s/zsh/zshrc\n" "$DATA_DIR" > "${zshrc_file}"
  logDone
}

function switchToZSH() {
  logTitle "🚧  Switching to ZSH..."
  if [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
    logDone
    return
  fi

  # Changing shell requires user input.
  enableTTY
  sudo chsh -s "$(which zsh)" "$(whoami)"
  disableTTY
  logDone
}

function installZSH() {
  installOhMyZSH
  setupZSHRC
  installZSHDraculaTheme
  switchToZSH
}

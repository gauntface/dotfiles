#!/bin/bash
set -euo pipefail

function installOhMyZSH() {
  logTitle "📦  Installing oh-my-zsh..."
  if [[ -n "${ZSH}" && -d "${ZSH}" ]]; then
    logDone
    return
  fi

  curl -sL "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" | zsh -
  logDone
}

function installZSHDraculaTheme() {
  logTitle "📦  Installing Dracula theme for zsh..."
  if [[ -n "${ZSH}" && -d "${ZSH}" ]]; then
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

  printf "source  %s/zsh/zshrc\n" "$DOTFILES_DIR" > "${zshrc_file}"
  logDone
}

function switchToZSH() {
  logTitle "🚧  Switching to ZSH..."
  if [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
    logDone
    return
  fi

  # Changing shell requires user input.
  chsh -s $(which zsh)
  logDone
}

function installZSH() {
  installOhMyZSH
  setupZSHRC
  installZSHDraculaTheme
  switchToZSH
}

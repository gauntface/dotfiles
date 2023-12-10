#!/bin/bash
set -euo pipefail

function initOSVar() {
  OS="$(uname -s)"
  case "${OS}" in
    Linux*)
      OS="${OS} - $(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs)"
      ;;
  esac

  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          ;;
      "Linux - Fedora"*)
          ;;
      Darwin*)
          # NOOP
          ;;
      *)
          echo -e "\t🤷 Unknown platform '${OS}'"
          exit 1
          ;;
  esac
  export OS
}

function initLogging() {
  TEMP_DIR="$(mktemp -d)"
  ERROR_LOG="${TEMP_DIR}/dotfiles-install.log"
  export ERROR_LOG

  touch "$ERROR_LOG"
  exec > "$ERROR_LOG" 2>&1
}

function logToUser() {
  # Echo to log file first.
  echo "$@"

  # Save the current stdout and stderr file descriptors
  exec 3>&1 4>&2
  # Temporarily redirect stdout and stderr to /dev/tty (terminal)
  exec 1>/dev/tty 2>&1
  # Echo the provided arguments to the terminal
  echo "$@"
  # Revert the redirection back to the log file
  exec 1>&3 2>&4
  # Close the saved file descriptors
  exec 3>&- 4>&-
}

function logDone() {
  # Add an extra line to the log file
  echo ""
  logToUser -e "\t✅  Done\n"
}

function logNewLine() {
  logToUser -e ""
}

function logTitle() {
  logToUser "$@"
  logNewLine
}

function setupDirectories() {
    PROJECTS_DIR="${HOME}/Projects"
    TOOLS_DIR="${HOME}/Projects/Tools"
    CODE_DIR="${HOME}/Projects/Code"
    DOTFILES_DIR="${TOOLS_DIR}/dotfiles"

    logTitle -e "📂  Setting up directories..."
    logToUser -e "\tProjects:\t${PROJECTS_DIR}"
    logToUser -e "\tTools:\t\t${TOOLS_DIR}"
    logToUser -e "\tCode:\t\t${CODE_DIR}"
    logNewLine

    mkdir -p "${PROJECTS_DIR}"
    mkdir -p "${TOOLS_DIR}"
    mkdir -p "${CODE_DIR}"

    logDone
}

function performUpdate() {
  logTitle -e "📦  Update system..."

  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          sudo apt-get update -y
          ;;
      "Linux - Fedora"*)
          sudo dnf update -y
          ;;
  esac
  logDone
}

function installDeps() {
    logTitle -e "📦  Installing dependencies..."

    case "${OS}" in
        "Linux - Ubuntu"* | "Linux - Debian"*)
            # shellcheck disable=SC2046
            sudo apt-get install -y $(cat ./dependencies/linux-packages.txt)
            # shellcheck disable=SC2046
            sudo apt-get install -y $(cat ./dependencies/debian-packages.txt)
            ;;
        "Linux - Fedora"*)
            # shellcheck disable=SC2046
            sudo dnf install -y $(cat ./dependencies/linux-packages.txt)
            # shellcheck disable=SC2046
            sudo dnf install -y $(cat ./dependencies/fedora-packages.txt)
            ;;
        Darwin*)
            brew bundle install --file ./dependencies/Brewfile
            ;;
    esac
    logDone
}

function installOhMyZSH() {
  logTitle -e "📦  Installing oh-my-zsh..."
  if [[ -n "${ZSH}" && -d "${ZSH}" ]]; then
    logDone
    return
  fi

  curl -sL "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" | zsh -
  logDone
}

function installZSHDraculaTheme() {
  logTitle -e "📦  Installing Dracula theme for zsh..."
  if [[ -n "${ZSH}" && -d "${ZSH}" ]]; then
    logDone
    return
  fi

  git clone https://github.com/dracula/zsh.git "${HOME}/.custom-zsh/themes/dracula"
  ln -s "${HOME}/.custom-zsh/themes/dracula/dracula.zsh-theme" "${HOME}/.custom-zsh/themes/dracula.zsh-theme"
  logDone
}

function setupZSHRC() {
  logTitle -e "🖥️  Setting up .zshrc..."

  local zshrc_file="${HOME}/.zshrc"

  if [ -L "${zshrc_file}" ] || [ -f "${zshrc_file}" ] ; then
    rm "${zshrc_file}"
  fi

  echo -e "source ${DOTFILES_DIR}/zsh/zshrc" > "${zshrc_file}"
  echo -e "\n\t✅  Done\n"
}

function switchToZSH() {
  logTitle -e "🚧  Switching to ZSH..."
  if [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
    logDone
    return
  fi

  # Changing shell requires user input.
  chsh -s $(which zsh)
  logDone
}

function setupGnomeTerminal() {
  logTitle -e "🖥️  Sett up Gnome terminal profiles..."
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"* | "Linux - Fedora"*)
        dconf load /org/gnome/terminal/legacy/profiles:/ < "${DOTFILES_DIR}/gnome-terminal/profiles.dconf"
        ;;
  esac
  logDone
}

# -e means 'enable interpretation of backslash escapes'
initOSVar
initLogging

logNewLine
logToUser -e "👢  Installing @gauntface's Dotfiles"
logToUser -e "\t👟  OS: ${OS}"
logToUser -e "\t🪵  Logs: ${ERROR_LOG}"
logNewLine

setupDirectories
performUpdate
installDeps

# TODO: We need to setup the dotfiles directory first.

# ZSH commands
installOhMyZSH
setupZSHRC
installZSHDraculaTheme
switchToZSH
setupGnomeTerminal

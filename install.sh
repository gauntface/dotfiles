#!/bin/bash
set -euo pipefail

source "./libs/logging.sh"
source "./libs/error-handling.sh"
source "./libs/optional-step.sh"

source "./steps/update.sh"
source "./steps/install-deps.sh"
source "./steps/install-chrome.sh"
source "./steps/install-zsh.sh"
source "./steps/gnome-terminal.sh"
source "./steps/setup-github.sh"

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
          echo "\t🤷 Unknown platform '${OS}'"
          exit 1
          ;;
  esac
  export OS
}

function setupDirectories() {
    PROJECTS_DIR="${HOME}/Projects"
    TOOLS_DIR="${HOME}/Projects/Tools"
    CODE_DIR="${HOME}/Projects/Code"
    DOTFILES_DIR="${TOOLS_DIR}/dotfiles"

    logTitle "📂  Setting up directories..."
    echo "\tProjects:\t${PROJECTS_DIR}"
    echo "\tTools:\t\t${TOOLS_DIR}"
    echo "\tCode:\t\t${CODE_DIR}"
    echo ""

    mkdir -p "${PROJECTS_DIR}"
    mkdir -p "${TOOLS_DIR}"
    mkdir -p "${CODE_DIR}"

    logDone
}

# -e means 'enable interpretation of backslash escapes'
initOSVar
initLogging

echo ""
echo "👢  Installing @gauntface's Dotfiles"
echo "\t👟  OS: ${OS}"
echo "\t🪵  Logs: ${ERROR_LOG}"
echo ""

setupDirectories
performUpdate
installDeps

# Offer Chrome install early in case we want to setup password etc
if [[ ! $(command -v "google-chrome") ]]; then
  optionalStep "install Chrome" installChrome
else
  logStepDone "Chrome already installed"
fi

if [[ ! $(git ls-remote "git@github.com:gauntface/dotfiles.git") ]]; then
  optionalStep "setup GitHub" setupGitHub
else
  logStepDone "GitHub already setup"
fi
# TODO: We need to setup the dotfiles directory first.


installZSH
setupGnomeTerminal

echo "🔚  All Done. Please reboot to complete.\n"

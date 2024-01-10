#!/bin/bash
set -euo pipefail

source "./libs/logging.sh"
source "./libs/error-handling.sh"
source "./libs/optional-step.sh"
source "./libs/directories.sh"

source "./steps/update.sh"
source "./steps/install-deps.sh"
source "./steps/install-chrome.sh"
source "./steps/install-zsh.sh"
source "./steps/gnome-terminal.sh"
source "./steps/setup-github.sh"
source "./steps/install-golang.sh"
source "./steps/install-github-cli.sh"
source "./steps/setup-git.sh"
source "./steps/install-node.sh"
source "./steps/install-vscode.sh"
source "./steps/setup-framework.sh"
source "./steps/setup-udev.sh"
source "./steps/setup-public-dotfiles.sh"
source "./steps/setup-private-dotfiles.sh"

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

# Offer VSCode install early in case we want to edit the dotfiles
if [[ ! $(command -v "code") ]]; then
  optionalStep "install VSCode" installVSCode
else
  logStepDone "VSCode already installed"
fi

# GitHub needs to be setup before we can clone the dotfiles
if [[ ! $(git ls-remote "git@github.com:gauntface/dotfiles.git") ]]; then
  optionalStep "setup GitHub" setupGitHub
else
  logStepDone "GitHub already setup"
fi

# Dotfiles are used to setup ZSH and Gnome Terminal
setupPublicDotfiles
installZSH
setupGnomeTerminal
setupGit

if [[ ! $(command -v "node") ]]; then
  optionalStep "install Node" installNode
else
  logStepDone "Node already installed"
fi

if [[ ! $(command -v "gh") ]]; then
  optionalStep "install GitHUB CLI" installGitHubCLI
else
  logStepDone "GitHub CLI already installed"
fi

optionalStep "install Golang" installGolang
optionalStep "setup Framework Laptop" setupFramework
optionalStep "setup Udev Rules" setupUdev
optionalStep "setup Private Dotfiles" setupPrivateDotfiles

echo "🎉  All Done. Please reboot to complete.\n"

#!/bin/bash

set -euo pipefail

<<<<<<< HEAD
# Catch and log errors
trap uncaughtError ERR

OS="$(uname -s)"
case "${OS}" in
	Linux*)
		OS="${OS} - $(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs)"
		;;
esac

function uncaughtError() {
  echo -e "\n\t❌  Error\n"
  echo "$(<${ERROR_LOG})"
  echo -e "\n\t😞  Sorry\n"
  exit $?
=======
function initOSVar() {
  OS="$(uname -s)"
  case "${OS}" in
    Linux*)
      OS="${OS}/$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs)"
      ;;
  esac
>>>>>>> c73f097 (Adding a new parse of dotfiles install)
}

function initVars() {
  initOSVar;

  echo -e "🔢 Creating global vars..."
  echo -e "\tOS:\t${OS}"
  echo ""
}

function initDirectories() {
  PROJECTS_DIR="${HOME}/Projects"
  TOOLS_DIR="${HOME}/Projects/Tools"
  CODE_DIR="${HOME}/Projects/Code"
  DOTFILES_DIR="${HOME}/Projects/Tools/dotfiles"
  TEMP_DIR="$(mktemp -d)"

  mkdir -p "${PROJECTS_DIR}"
  mkdir -p "${TOOLS_DIR}"
  mkdir -p "${CODE_DIR}"

  echo -e "📂  Using directories..."
  echo -e "\tProjects:\t${PROJECTS_DIR}"
  echo -e "\tTools:\t\t${TOOLS_DIR}"
  echo -e "\tCode:\t\t${CODE_DIR}"
  echo -e "\tDotfiles:\t${DOTFILES_DIR}"
  echo -e "\tTemp:\t\t${TEMP_DIR}"
  echo -e ""
}

<<<<<<< HEAD
function performUpdate() {
  echo -e "📦  Update system..."

  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          sudo apt-get update -y
          ;;
      "Linux - Fedora"*)
          sudo dnf update -y
          ;;
      Darwin*)
          # NOOP
          ;;
      *)
          # NOOP
          echo -e "\t🤷 Unknown platform '${OS}'"
          ;;
  esac
  echo -e "\n\t✅  Done\n"
}

function installCommonDeps() {
  echo -e "📦  Installing common dependencies..."
  deps="gimp inkscape"
  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          sudo apt-get install -y $deps build-essential synaptic gparted pdfsam xdg-utils gnome-tweaks &> ${ERROR_LOG}
          ;;
      "Linux - Fedora"*)
          sudo dnf install -y \
            $deps \
            pdfshuffler \
            gcc-c++ \
            transmission \
            xdg-utils \
            gnome-tweaks \
            webp-pixbuf-loader \
            avif-pixbuf-loader \
            direnv
          ;;
      Darwin*)
          # NOOP
          ;;
      *)
          # NOOP
          echo -e "\t🤷 Unknown OS '${OS}'"
          ;;
  esac
  echo -e "\n\t✅  Done\n"
}

function setupGit() {
  echo -e "🖥️  Setting up Git..."
  echo "${DOTFILES_DIR}/git/global-ignore"
  git config --global core.excludesfile "${DOTFILES_DIR}/git/global-ignore"
  git config --global user.name "Matt Gaunt-Seo"
  git config --global pull.rebase true
  git config --global push.autoSetupRemote true
  git config --global fetch.prune true

  read -p "📧  What email would you like to use for your Git commits? [matt@gaunt.dev] " GIT_EMAIL
  GIT_EMAIL=${GIT_EMAIL:-"matt@gaunt.dev"}
  echo -e "\nDoes this look right? (Please enter a number)"
  echo -e "\n\t${GIT_EMAIL}\n"
  select yn in "Yes" "No (Retry)"; do
      case $yn in
          Yes )
              echo ""
              git config --global user.email "${GIT_EMAIL}"
              break;;
          "No (Retry)" )
              setupGit
              break;;
      esac
  done
  echo -e "\n\t✅  Done\n"
}

function installNode() {
  # Install Node and NPM - https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
  echo -e "📦  Installing Node.js..."
  if ! [ -x "$(command -v node)" ]; then
    NODE_VERSION=18
    case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo bash - &> ${ERROR_LOG}
          sudo apt-get install -y nodejs &> ${ERROR_LOG}
          ;;
      "Linux - Fedora"*)
          curl -sL https://rpm.nodesource.com/setup_${NODE_VERSION}.x | sudo bash - &> ${ERROR_LOG}
          sudo dnf install -y nodejs &> ${ERROR_LOG}
          ;;
      *)
          # NOOP
          echo -e "\t🤷 Unknown os '${OS}'"
          ;;
    esac
  fi
  global_dir="${HOME}/.npm-packages"
  echo -e "\n\tMaking global directory '${global_dir}'\n"
  mkdir -p "${global_dir}/lib"
  echo -e "\t✅  Done\n"
}

function installZSH() {
  # Check if shell end with /bin/zash
  if [[ "${SHELL}" == *"/bin/zsh" ]]; then
    return
  fi

  echo -e "📦  Installing ZSH..."
=======
function doChromeInstall() {
  echo -e "🌎  Installing Chrome..."
  chrome_version="google-chrome-stable"
>>>>>>> c73f097 (Adding a new parse of dotfiles install)
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
			if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
					wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -

<<<<<<< HEAD
  echo -e "📦  Installing oh-my-zsh..."
  curl -sL "https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh" | zsh - &> ${ERROR_LOG}
  echo -e "\n\t✅  Done\n"
}

function setupZSHRC() {
  echo -e "🖥️  Setting up .zshrc..."
  ZSH_FILE="${HOME}/.zshrc"
  if [ -L "${ZSH_FILE}" ] || [ -f "${ZSH_FILE}" ] ; then
    rm "${ZSH_FILE}" &> ${ERROR_LOG}
  fi

  echo -e "source ${DOTFILES_DIR}/zsh/zshrc" > "${ZSH_FILE}"

  rm -rf "${HOME}/.custom-zsh/themes"
  git clone https://github.com/dracula/zsh.git "${HOME}/.custom-zsh/themes/dracula" &> ${ERROR_LOG}
  ln -s ${HOME}/.custom-zsh/themes/dracula/dracula.zsh-theme ${HOME}/.custom-zsh/themes/dracula.zsh-theme &> ${ERROR_LOG}

  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
        dconf load /org/gnome/terminal/legacy/profiles:/ < "${DOTFILES_DIR}/gnome-terminal/profiles.dconf"
        ;;
    "Linux - Fedora"*)
        # util-linux-user provide chsh
        dconf load /org/gnome/terminal/legacy/profiles:/ < "${DOTFILES_DIR}/gnome-terminal/profiles.dconf"
        ;;
    *)
        # NOOP
        ;;
  esac
  echo -e "\n\t✅  Done\n"
}

function switchToZSH() {
  # Check if shell end with /bin/zash
  if [[ "${SHELL}" == *"/bin/zsh" ]]; then
    return
  fi

  echo -e "🚧  Switching to ZSH..."
  # Changing shell requires user input.
  chsh -s "$(which zsh)"
  echo -e "\n\t✅  Done\n"
}

function installGauntfacePlymouth() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "📦  Installing Gauntface Plymouth Theme..."
  case "${OS}" in
      Linux*)
          source "${DOTFILES_DIR}/plymouth/install.sh"
          ;;
      Darwin*)
          # NOOP
          ;;
      *)
          # NOOP
          echo -e "\t🤷 Unknown operating system '${OS}'"
          ;;
  esac
  echo -e "\n\t✅  Done\n"
}

function installVSCode() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "📝  Installing VSCode..."
  case "${OS}" in
		"Linux - Ubuntu"* | "Linux - Debian"*)
			curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
			sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
			rm microsoft.gpg
			if [ ! -f /etc/apt/sources.list.d/vscode.list ]; then
				sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' &> ${ERROR_LOG}
=======
					sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
>>>>>>> c73f097 (Adding a new parse of dotfiles install)
			fi
			sudo apt-get update
			sudo apt-get install -y $chrome_version
			;;
    "Linux - Fedora"*)
			sudo dnf install fedora-workstation-repositories
			sudo dnf config-manager --set-enabled google-chrome
			sudo dnf install -y $chrome_version
			;;
    Darwin*)
			# NOOP
			;;
    *)
			echo "Running on unknown OS: ${OS}"
			uncaughtError
			exit 1
			;;
    esac

  # Try and open chrome since it may have been install in the previous step but do not error if it fails
  (google-chrome gauntface.com || true) &> /dev/null &

  echo -e "\t👷 Please setup Chrome and press enter to continue\n"
  read -r -p ""

  echo -e "\n\t✅  Done\n"
}

function installChrome() {
  if which "google-chrome" >/dev/null 2>&1; then
    echo "🌎  google-chrome is already installed."
    return
  fi

  echo -e "🌎  Would you like to install Chrome? (Please enter a number)"
  select yn in "Yes" "No (Skip)"; do
      case $yn in
          Yes )
              echo ""
              doChromeInstall
              break;;
          "No (Skip)" )
              break;;
      esac
  done
}

# -e means 'enable interpretation of backslash escapes'
echo -e "\n📓  Installing @gauntface's Dotfiles\n"

initVars;

initDirectories;

installChrome;

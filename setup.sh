#!/bin/bash

# Catch and log errors
trap uncaughtError ERR

OS="$(uname -s)"
case "${OS}" in
	Linux*)
		OS="${OS} - $(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs)"
		;;
esac

function uncaughtError {
  echo -e "\n\t❌  Error\n"
  echo "$(<${ERROR_LOG})"
  echo -e "\n\t😞  Sorry\n"
  exit $?
}

function initDirectories() {
  PROJECTS_DIR="${HOME}/Projects"
  TOOLS_DIR="${HOME}/Projects/Tools"
  CODE_DIR="${HOME}/Projects/Code"
  DOTFILES_DIR="${HOME}/Projects/Tools/dotfiles"
  PRIV_DOTFILES_DIR="${HOME}/Projects/Tools/private-dotfiles"
  TEMP_DIR="$(mktemp -d)"
  ERROR_LOG="${TEMP_DIR}/dotfile-install-err.log"

  echo -e "📂  Using directories..."
  echo -e "\tProjects:\t${PROJECTS_DIR}"
  echo -e "\tTools:\t\t${TOOLS_DIR}"
  echo -e "\tCode:\t\t${CODE_DIR}"
  echo -e "\tDotfiles:\t${DOTFILES_DIR}"
  echo -e "\tTemp:\t\t${TEMP_DIR}"
  echo -e ""
}

function performUpdate() {
  echo -e "📦  Update system..."

  case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          sudo apt-get update -y
          ;;
      "Linux - Fedora"*)
          sudo dnf update -y
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
            avif-pixbuf-loader
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
  git config --global core.excludesfile "${DOTFILES_DIR}/git/global-ignore"
  git config --global user.email "matt@gaunt.dev"
  git config --global user.name "Matt Gaunt"
  echo -e "\n\t✅  Done\n"
}

function installNode() {
  # Install Node and NPM - https://nodejs.org/en/download/package-manager/#debian-and-ubuntu-based-linux-distributions
  echo -e "📦  Installing Node.js..."
  if ! [ -x "$(command -v node)" ]; then
    NODE_VERSION=16
    case "${OS}" in
      "Linux - Ubuntu"* | "Linux - Debian"*)
          curl -sL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo bash - &> ${ERROR_LOG}
          sudo apt-get install -y nodejs &> ${ERROR_LOG}
          ;;
      "Linux - Fedora"*)
          sudo dnf module install -y nodejs:${NODE_VERSION} &> ${ERROR_LOG}
          ;;
      *)
          # NOOP
          echo -e "\t🤷 Unknown os '${OS}'"
          ;;
    esac
  fi
  echo -e "\n\t✅  Done\n"
}

function setupNPM() {
  echo -e "️️🖥️  Setting up NPM..."
  # mkdir "${HOME}/.npm-packages"
  # npm config set prefix "${HOME}/.npm-packages"

  # curl -sL https://raw.githubusercontent.com/glenpike/npm-g_nosudo/master/npm-g-nosudo.sh | sh - &> ${ERROR_LOG}
  echo -e "\n\t✅  Done\n"
}

function installZSH() {
  if [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
    return
  fi

  echo -e "📦  Installing ZSH..."
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
        sudo apt-get install -y zsh &> ${ERROR_LOG}
        ;;
    "Linux - Fedora"*)
        # util-linux-user provide chsh
        sudo dnf install -y zsh util-linux-user &> ${ERROR_LOG}
        ;;
    *)
        # NOOP
        echo -e "\t🤷 Unknown platform '${OS}'"
        ;;
  esac

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

  git clone https://github.com/dracula/zsh.git "${HOME}/.custom-zsh/themes/dracula" &> ${ERROR_LOG}
  ln -s ${HOME}/.custom-zsh/themes/dracula/dracula.zsh-theme ${HOME}/.custom-zsh/themes/dracula.zsh-theme &> ${ERROR_LOG}

  dconf load /org/gnome/terminal/legacy/profiles:/ < "${DOTFILES_DIR}/gnome-terminal/profiles.dconf"
  echo -e "\n\t✅  Done\n"
}

function switchToZSH() {
  if [[ "${SHELL}" = "/usr/bin/zsh" ]]; then
    return
  fi

  echo -e "🚧  Switching to ZSH..."
  # Changing shell requires user input.
  chsh -s $(which zsh)
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
			fi
			sudo apt-get update &> ${ERROR_LOG}
			sudo apt-get install -y code &> ${ERROR_LOG}
			;;
    "Linux - Fedora"*)
			sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
			cat <<EOF | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
			sudo dnf check-update  &> ${ERROR_LOG}
			sudo dnf install -y code  &> ${ERROR_LOG}
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

function installEmojiFont() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "📝  Installing Emoji..."
  case "${OS}" in
    "Linux - Ubuntu"* | "Linux - Debian"*)
			sudo apt-get install -y fonts-noto-color-emoji &> ${ERROR_LOG}
			;;
		"Linux - Fedora"*)
    	# NOOP
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

function installGo() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "📝  Installing Go..."
  case "${OS}" in
      Linux*)
          source "${DOTFILES_DIR}/golang/install.sh"
          ;;
      Darwin*)
          # NOOP
          ;;
      *)
          # NOOP
          ;;
  esac
  echo -e "\n\t✅  Done\n"
}

function setupPrivateDotfiles() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "️️🖥️  Setting up Private dotfiles..."
  git clone git@github.com:gauntface/private-dotfiles.git ${PRIV_DOTFILES_DIR} &> ${ERROR_LOG}
  source "${PRIV_DOTFILES_DIR}/setup.sh"
  echo -e "\n\t✅  Done\n"
}

function powerForFramework() {
  echo ""
  echo -e "️️⚡  Improve power for the Framework..."
  echo -e "\nWould you like to use the 'nvme.noacpi=1' kernel flag? (Please enter a number)"
  select yn in "Yes" "No (Skip)"; do
      case $yn in
          Yes )
              echo ""
              sudo grubby --update-kernel=ALL --args="nvme.noacpi=1"
              break;;
          "No (Skip)" )
              break;;
      esac
  done
  echo -e "\n\t✅  Done\n"
}

function setupCorpSpecific() {
  if [[ "${IS_CORP_INSTALL}" = false ]]; then
    return
  fi

  echo "💼  Would you like to set up corp specific dotfiles?  (Please enter a number)"
  select yn in "Yes" "No"; do
      case $yn in
          Yes )
              getCorpCommand
              break;;
          No )
              break;;
      esac
  done
  echo ""
}

function getCorpCommand() {
  echo ""
  read -p "Please enter the command from http://go/user.git/mattgaunt/dotfiles : " CORP_COMMAND
  echo -e "\nDoes this look right? (Please enter a number)"
  echo -e "\n\t${CORP_COMMAND}\n"
  select yn in "Yes" "No (Retry)" "No (Skip)"; do
      case $yn in
          Yes )
              echo ""
              eval $CORP_COMMAND
              break;;
          "No (Retry)" )
              getCorpCommand
              break;;
          "No (Skip)" )
              break;;
      esac
  done
  echo ""
}

# -e means 'enable interpretation of backslash escapes'
echo -e "\n📓  Installing @gauntface's Dotfiles\n"

initDirectories

performUpdate

installCommonDeps

setupGit

installNode

installZSH

setupZSHRC

switchToZSH

# Setup NPM *after* ZSH to ensure it's configured for ZSH correctly
setupNPM

installGo

installVSCode

installEmojiFont

installGauntfacePlymouth

powerForFramework

setupPrivateDotfiles

setupCorpSpecific

echo -e "🎉  Finished, reboot to complete.\n"

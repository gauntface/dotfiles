#!/bin/bash

set -eo pipefail

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

function isCorpInstall() {
  if [[ -z "${DEPLOY_ENV}" ]]; then
    echo "💼  Is this a corp install? (Please enter a number)"
    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                IS_CORP_INSTALL=true
                break;;
            No )
                IS_CORP_INSTALL=false
                break;;
        esac
    done
    echo ""
  fi

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

  if [[ "${IS_CORP_INSTALL}" = false ]]; then
    git config --global user.email "matt@gaunt.dev"
  else
    read -p "Please enter your corp email: " CORP_EMAIL
    echo -e "\nDoes this look right? (Please enter a number)"
    echo -e "\n\t${CORP_EMAIL}\n"
    select yn in "Yes" "No (Retry)" "No (Skip)"; do
        case $yn in
            Yes )
                echo ""
                git config --global user.email "${CORP_EMAIL}"
                break;;
            "No (Retry)" )
                setupGit
                break;;
            "No (Skip)" )
                break;;
        esac
    done
  fi
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
    Darwin*)
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
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
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

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

function setupArduinoDevices() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "📝  Setting up arduino/device hacking..."
  case "${OS}" in
      Linux*)
          sudo usermod -a -G dialout $USER
          sudo cp -R "$DOTFILES_DIR/udev/." "/etc/udev/rules.d/"
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

isCorpInstall

initDirectories

performUpdate

installCommonDeps

setupGit

installNode

installZSH

setupZSHRC

switchToZSH

installGo

installVSCode

installEmojiFont

installGauntfacePlymouth

powerForFramework

setupArduinoDevices

setupPrivateDotfiles

setupCorpSpecific

echo -e "🎉  Finished, reboot to complete.\n"

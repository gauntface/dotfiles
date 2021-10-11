#!/bin/bash

# Catch and log errors
trap uncaughtError ERR

PLATFORM="$(awk -F= '/^NAME/{print $2}' /etc/os-release | xargs)"
OS="$(uname -s)"

function uncaughtError {
  echo -e "\n\t❌  Error\n"
  if [[ ! -z "${ERROR_LOG}" ]]; then
    echo -e "\t$(<${ERROR_LOG})"
  fi
  echo -e "\n\t😞  Sorry\n"
  exit $?
}

function isCorpInstall() {
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
}

function setupDirectories() {
    PROJECTS_DIR="${HOME}/Projects"
    TOOLS_DIR="${HOME}/Projects/Tools"
    CODE_DIR="${HOME}/Projects/Code"
    DOTFILES_DIR="${HOME}/Projects/Tools/dotfiles"
    TEMP_DIR="$(mktemp -d)"
    ERROR_LOG="${TEMP_DIR}/dotfile-install-err.log"

    echo -e "📂  Setting up directories..."
    echo -e "\tProjects:\t${PROJECTS_DIR}"
    echo -e "\tTools:\t\t${TOOLS_DIR}"
    echo -e "\tCode:\t\t${CODE_DIR}"
    echo -e "\tTemp:\t\t${TEMP_DIR}"
    mkdir -p ${PROJECTS_DIR}
    mkdir -p ${TOOLS_DIR}
    mkdir -p ${CODE_DIR}
    echo -e "\n\t✔️  Done\n"
}

function installChrome() {
  if [[ "${IS_CORP_INSTALL}" = true ]]; then
    return
  fi

  echo -e "🌎  Installing Chrome..."
  chrome_version="google-chrome-stable"
  case "${PLATFORM}" in
      Ubuntu* | Debian*)
          if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
            wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - &> ${ERROR_LOG}

	    sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' &> ${ERROR_LOG}
	  fi
          sudo apt-get update &> ${ERROR_LOG}
          sudo apt-get install -y $chrome_version &> ${ERROR_LOG}
          ;;
      Fedora*)
          sudo dnf install fedora-workstation-repositories &> ${ERROR_LOG}
          sudo dnf config-manager --set-enabled google-chrome &> ${ERROR_LOG}
          sudo dnf install -y $chrome_version &> ${ERROR_LOG}
          ;;
      *)
            echo "Running on unknown platform: ${PLATFORM}" > "$ERROR_LOG"
            uncaughtError
            exit 1
            ;;
  esac

  # Try and open chrome since it may have been install in the previous step but do not error if it fails
  (google-chrome gauntface.com || true) &> /dev/null &

  echo -e "\t👷 Please setup Chrome and press enter to continue\n"
  read -p ""

  echo -e "\n\t✅  Done\n"
}

function installGit() {
    echo -e "📦  Installing git + deps..."

    deps="git xclip"
    case "${PLATFORM}" in
        Ubuntu* | Debian*)
            sudo apt-get install -y $deps &> ${ERROR_LOG}
            ;;
        Fedora*)
            sudo dnf install -y $deps &> ${ERROR_LOG}
            ;;
        *)
            echo "Running on unknown platform: ${PLATFORM}" > "$ERROR_LOG"
            uncaughtError
            exit 1
            ;;
    esac
    echo -e "\n\t✅  Done\n"
}

function setupSSHKeys() {
    echo -e "🔑  Setting up SSH Key..."
    expected_ssh_file=".ssh/id_ed25519"
    if [ ! -f "${HOME}/${expected_ssh_file}" ] ; then
        ssh-keygen -t ed25519 -C "hello@gaunt.dev"
        eval "$(ssh-agent -s)" &> ${ERROR_LOG}
        ssh-add "~/${expected_ssh_file}"
    fi


    case "${OS}" in
        Linux*)
            xclip -selection clipboard < ~/${expected_ssh_file}.pub
            ;;
        Darwin*)
            pbcopy < ~/${expected_ssh_file}.pub
            ;;
        *)
            echo "Running on unknown OS: ${OS}" > "$ERROR_LOG"
            uncaughtError
            exit 1
            ;;
    esac

  echo -e "📋  Your SSH key has been copied to your clipboard, please add it to https://github.com/settings/keys"

  # Try and open chrome since it may have been install in the previous step but do not error if it fails
  google-chrome github.com/settings/keys || true

  read -p "Press enter to continue"

  echo -e "\n\t✅  Done\n"
}

function cloneDotfiles() {
    echo -e "🖥  Cloning dotfiles..."
    if [[ "${IS_CORP_INSTALL}" = true ]]; then
        git clone https://github.com/gauntface/dotfiles.git ${DOTFILES_DIR} &> ${ERROR_LOG}
    else
        git clone git@github.com:gauntface/dotfiles.git ${DOTFILES_DIR} &> ${ERROR_LOG}
    fi

    (cd $DOTFILES_DIR; git fetch origin)
    (cd $DOTFILES_DIR; git reset origin/main --hard)
    echo -e "\n\t✅  Done\n"
}

function runSetup() {
    echo -e "👢 Bootstrap complete...\n"
    case "${OS}" in
        Linux*)
            # `source` is used so the script inherits environment variables
            source "${DOTFILES_DIR}/setup.sh"
            ;;
        Darwin*)
            source "${DOTFILES_DIR}/setup.sh"
            ;;
        *)
            echo "Running on unknown environment: ${unameOut}" > "$ERROR_LOG"
            uncaughtError
            exit 1
            ;;
    esac
}

# -e means 'enable interpretation of backslash escapes'
echo -e "\n👢  Bootstrapping @gauntface's Dotfiles"
echo -e "👟 Running on ${PLATFORM}\n"

isCorpInstall

setupDirectories

# Install Chrome first so we can set up GitHub with passwords etc next
installChrome

installGit

setupSSHKeys

cloneDotfiles

runSetup

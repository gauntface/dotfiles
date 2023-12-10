#!/bin/bash

set -eo pipefail




<<<<<<< HEAD
  echo -e "📋  Your SSH key has been copied to your clipboard, please add it to https://github.com/settings/keys"

  case "${OS}" in
        Linux*)
            # Try and open chrome since it may have been install in the previous step but do not error if it fails
            google-chrome "https://github.com/settings/keys" || true
            ;;
        Darwin*)
            open "https://github.com/settings/keys" || true
            ;;
        *)
            echo "Running on unknown OS: ${OS}" > "$ERROR_LOG"
            uncaughtError
            exit 1
            ;;
    esac

  read -p "Press enter to continue"

  echo -e "\n\t✅  Done\n"
}
=======
>>>>>>> e12a541 (Some small fixes)

function cloneDotfiles() {
    echo -e "🖥  Cloning dotfiles..."
    git clone git@github.com:gauntface/dotfiles.git ${DOTFILES_DIR} &> ${ERROR_LOG}

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

installGit

setupSSHKeys

cloneDotfiles

runSetup

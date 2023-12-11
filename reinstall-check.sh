#!/bin/bash
set -euo pipefail

source "./libs/logging.sh"
source "./libs/error-handling.sh"
source "./libs/optional-step.sh"

function checkUncommittedWork() {
    echo -e "🛠️  Check uncommitted work...\n"

    cd $PROJECTS_DIR && find . -type d -name '.git' | while read dir ; do sh -c "cd $dir/../ && echo -e \"\nStatus in ${dir//\.git/}\n\" && git status -s" ; done

    echo -e "\n\t️Come back once all work is committed...\n"

    select yn in "Done" "Stop"; do
        case $yn in
            Done )
                echo -e "\n\t✅  Done\n"
                break;;
            Stop )
                echo -e "\n\t🛑 Stopping script due to uncommited work.\n"
                exit 123;;
        esac
    done
}

function checkTerminalProfile() {
    echo -e "🛠️  Check gnome terminal profile is up-to-date...\n"

    dconf dump /org/gnome/terminal/legacy/profiles:/ > "${DOTFILES_DIR}/gnome-terminal/profiles.dconf"

    echo -e "\n\t✅  Done\n"
}

# -e means 'enable interpretation of backslash escapes'
echo -e "\n🗳️  Checks to run before re-installing OS\n"

checkUncommittedWork

checkTerminalProfile

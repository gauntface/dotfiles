#!/bin/bash
set -euo pipefail

source "./libs/logging.sh"
source "./libs/error-handling.sh"
source "./libs/directories.sh"

source "./steps/init-os.sh"
source "./steps/check-installed-pkgs.sh"
source "./steps/check-gnome-dock.sh"
source "./steps/check-wallpaper.sh"

projects_dir=${PROJECTS_DIR-"${HOME}/Projects"}
data_dir=${DATA_DIR-"${HOME}/Projects/Tools/dotfiles/data"}

function checkUncommittedWork() {
    echo "🛠️  Check uncommitted work...\n"

    enableTTY
    cd "${projects_dir}" && find . -type d -name '.git' | while read -r dir ; do sh -c "cd $dir/../ && echo -e \"\nStatus in ${dir//\.git/}\n\" && git status -s" ; done
    disableTTY

    echo "\n\t️Come back once all work is committed...\n"

    enableTTY
    select yn in "Done" "Stop"; do
        case $yn in
            Done )
                disableTTY
                logDone
                break;;
            Stop )
                echo "\n\t🛑 Stopping script due to uncommited work.\n"
                exit 123;;
        esac
    done
}

function checkTerminalProfile() {
    echo "🛠️  Check gnome terminal profile is up-to-date...\n"

    dconf dump /org/gnome/terminal/legacy/profiles:/ > "${data_dir}/gnome-terminal/profiles.dconf"

    logDone
}

initOSVar
initLogging

echo ""
echo "🗳️  Checks to run before re-installing OS"
echo "\t🪵  Logs: ${ERROR_LOG}"
echo ""

setupDirectories

checkUncommittedWork

checkTerminalProfile

checkInstalledPackages

checkGnomeDock

checkWallpaper

#!/bin/bash
set -euo pipefail

function setupDirectories() {
    PROJECTS_DIR="${HOME}/Projects"
    TOOLS_DIR="${HOME}/Projects/Tools"
    CODE_DIR="${HOME}/Projects/Code"
    DOTFILES_DIR="${TOOLS_DIR}/dotfiles"
    # shellcheck disable=SC2034
    DATA_DIR="${DOTFILES_DIR}/data"
    # shellcheck disable=SC2034
    PRIV_DOTFILES_DIR="${HOME}/Projects/Tools/private-dotfiles"

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

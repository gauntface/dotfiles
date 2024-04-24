#!/bin/bash
set -euo pipefail

function downloadGo() {
    echo "\t📂  Downloading go..."
    latestVersion=$(curl -s "https://go.dev/VERSION?m=text" | head -n1)
    GO_TAR="${latestVersion}.linux-amd64.tar.gz"

    if [ -f "${GO_TAR}" ]
    then
        rm "${GO_TAR}" # Remove file if it already exists
    fi
    wget --quiet "https://go.dev/dl/${GO_TAR}"
}

function deleteOldGo() {
    if [ ! -d "${GO_DIR}" ]
    then
        return
    fi

    echo "\t🗑️  Deleting previous go installation in ${GO_DIR}..."
    sudo rm -rf "${GO_DIR}"
}

function unpackGo() {
    echo "\t📂  Unpacking go to /usr/local..."

    sudo tar -C /usr/local -xzf "${GO_TAR}"
}

function deleteTar() {
    echo "\t🗑️  Deleting go tar..."
    rm "${GO_TAR}"
}

function installGolang() {
    case "${OS}" in
        Linux*)
            logTitle "📦  Installing Golang..."
            downloadGo

            deleteOldGo

            unpackGo

            deleteTar
            ;;
        *)
            return;;
  esac
}

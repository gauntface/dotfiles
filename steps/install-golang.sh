#!/bin/bash
set -euo pipefail

function downloadGo() {
    echo -e "\t📂  Downloading go..."
    latestVersion="$(curl -s https://go.dev/VERSION?m=text)"
    GO_TAR="${latestVersion}.linux-amd64.tar.gz"

    if [ -f "${GO_TAR}" ]
    then
        rm "${GO_TAR}" # Remove file if it already exists
    fi
    wget --quiet "https://dl.google.com/go/${GO_TAR}"
}

function deleteOldGo() {
    if [ ! -d "${GO_DIR}" ]
    then
        return
    fi

    echo -e "\t🗑️  Deleting previous go installation in ${GO_DIR}..."
    sudo rm -rf "${GO_DIR}"
}

function unpackGo() {
    echo -e "\t📂  Unpacking go to /usr/local..."

    sudo tar -C /usr/local -xzf "${GO_TAR}"
}

function deleteTar() {
    echo -e "\t🗑️  Deleting go tar..."
    rm "${GO_TAR}"
}

function installGolang() {
    logTitle "📦  Installing Golang..."

    downloadGo

    deleteOldGo

    unpackGo

    deleteTar
}

#!/bin/bash

# Catch and log errors
trap uncaughtError ERR

function uncaughtError {
  echo -e "\n\tâ  Error\n"
  if [[ ! -z "${ERROR_LOG}" ]]; then
    echo -e "\t$(<${ERROR_LOG})"
  fi
  echo -e "\n\tğ  Sorry\n"
  exit $?
}


function initTempDir() {
    TEMP_DIR="$(mktemp -d)"
    ERROR_LOG="${TEMP_DIR}/dotfile-install-err.log"
    GO_DIR="/usr/local/go/"
}

function downloadGo() {
    echo -e "\tğ  Downloading go..."
    latestVersion="$(curl -s https://golang.org/VERSION?m=text)"
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

    echo -e "\tğï¸  Deleting previous go installation in ${GO_DIR}..."
    sudo rm -rf "${GO_DIR}"
}

function unpackGo() {
    echo -e "\tğ  Unpacking go to /usr/local..."

    sudo tar -C /usr/local -xzf "${GO_TAR}"
}

function deleteTar() {
    echo -e "\tğï¸  Deleting go tar..."
    rm "${GO_TAR}"
}

initTempDir

downloadGo

deleteOldGo

unpackGo

deleteTar
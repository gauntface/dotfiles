#!/bin/bash

# Catch and log errors
trap uncaughtError ERR

PLATFORM="$(awk -F= '/^NAME/{print $2}' /etc/os-release)"

function uncaughtError {
  echo -e "\n\t❌  Error\n"
  echo "$(<${ERROR_LOG})"
  echo -e "\n\t😞  Sorry\n"
  exit $?
}

function initTempDir() {
    TEMP_DIR="$(mktemp -d)"
    ERROR_LOG="${TEMP_DIR}/dotfile-install-err.log"
}

function install() {
	THEME='gauntface'
	INSTALLDIR=/usr/share/plymouth/themes
	SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	THEME_DIR="${SCRIPT_DIR}/${THEME}/"

	echo -e "\n\t📦️  Installing Plymouth X11 tool..."
	case "${PLATFORM}" in
          Ubuntu*)
              sudo apt-get install plymouth-x11 -y &> ${ERROR_LOG}
              ;;
          Fedora*)
              sudo dnf install -y plymouth-plugin-script &> ${ERROR_LOG}
              ;;
          *)
              # NOOP
              echo -e "\t🤷 Unknown platform '${PLATFORM}'"
              ;;
        esac

	echo -e "\n\t✂️  Copying over theme files..."
	sudo rm -rf ${INSTALLDIR}/${THEME}
	sudo mkdir -p ${INSTALLDIR}/${THEME}
	sudo cp -rf ${THEME_DIR}/* ${INSTALLDIR}/${THEME}

	case "${PLATFORM}" in
          Ubuntu*)
              echo -e "\n\t📦️  Installing theme..."
	      sudo update-alternatives --quiet --install ${INSTALLDIR}/default.plymouth default.plymouth ${INSTALLDIR}/${THEME}/${THEME}.plymouth 100
	      
	      echo -e "\n\t➕️  Selecting theme..."
	      sudo update-alternatives --quiet --set default.plymouth ${INSTALLDIR}/${THEME}/${THEME}.plymouth
	      
	      echo -e "\n\t🧪  Updating initramfs..."
	      sudo update-initramfs -u &> ${ERROR_LOG}
              ;;
          Fedora*)
              echo -e "\n\t➕️  Selecting theme..."
              sudo plymouth-set-default-theme -R gauntface
              ;;
          *)
              # NOOP
              echo -e "\t🤷 Unknown platform '${PLATFORM}'"
              ;;
        esac
}

initTempDir
install

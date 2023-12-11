#!/bin/bash
set -euo pipefail

function createGitHubKey() {
  logTitle "🔑  Creating GitHub key..."
  local expected_ssh_file=$1
  if [[ -f "${expected_ssh_file}" ]]; then
      logDone
      return
  fi

  enableTTY

  ssh-keygen -t ed25519 -C "hello@gaunt.dev" -f "${expected_ssh_file}"

  disableTTY

  eval "$(ssh-agent -s)"
  ssh-add "${expected_ssh_file}"

  logDone
}

function setupSSHKeys() {
    local expected_ssh_file="${HOME}/.ssh/github"

    createGitHubKey "$expected_ssh_file"

    echo "🔑  Setting up GitHub SSH Key..."
    echo "\tSSH Key: ${expected_ssh_file}"
    echo "\tSSH Public Key: ${expected_ssh_file}.pub"
    echo ""

    case "${OS}" in
        Linux*)
            xclip -selection clipboard < "${expected_ssh_file}.pub"
            ;;
        Darwin*)
            pbcopy < "${expected_ssh_file}.pub"
            ;;
    esac

  echo "\t📋  Your SSH public key has been copied to your clipboard, please add it to https://github.com/settings/keys"

  # Try and open chrome since it may have been install in the previous step but do not error if it fails
  xdg-open "http://github.com/settings/keys" > /dev/null 2>&1

  echo "\t⏳  Press enter to continue..."
  read -r

  logDone
}

function setupGitHub() {
  setupSSHKeys
}

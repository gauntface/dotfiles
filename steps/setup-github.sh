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

function copyToClipboard() {
  local file=$1

  # Best-effort remote clipboard copy via the OSC 52 terminal escape sequence.
  # Terminals that support it (iTerm2, kitty, WezTerm, Windows Terminal, etc.)
  # forward this through SSH to the *local* machine's clipboard, even though
  # the remote box has no display. There's no way to detect if this worked,
  # so it's fired as a bonus alongside whatever else we can do below.
  printf '\e]52;c;%s\a' "$(base64 < "${file}" | tr -d '\n')" 2>/dev/null > /dev/tty || true

  case "${OS}" in
      Linux*)
          if [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy > /dev/null 2>&1; then
              wl-copy < "${file}"
              return 0
          elif [[ -n "${DISPLAY:-}" ]] && command -v xclip > /dev/null 2>&1; then
              xclip -selection clipboard < "${file}"
              return 0
          fi
          ;;
      Darwin*)
          pbcopy < "${file}"
          return 0
          ;;
  esac

  return 1
}

function setupSSHKeys() {
    local expected_ssh_file="${HOME}/.ssh/github"

    createGitHubKey "$expected_ssh_file"

    echo "🔑  Setting up GitHub SSH Key..."
    echo "\tSSH Key: ${expected_ssh_file}"
    echo "\tSSH Public Key: ${expected_ssh_file}.pub"
    echo ""

    if copyToClipboard "${expected_ssh_file}.pub"; then
        echo "\t📋  Your SSH public key has been copied to your clipboard, please add it to https://github.com/settings/keys"
    else
        logWarning "No clipboard tool found on this machine (e.g. no xclip/wl-copy, or no display)."
        echo "\tWe also tried a terminal-based copy (OSC 52) which some SSH clients support - check your local clipboard just in case."
        echo "\tOtherwise, here's your public key to copy manually:"
        echo ""
        echo "$(cat "${expected_ssh_file}.pub")"
        echo ""
        echo "\tAdd it to https://github.com/settings/keys"
    fi

  # Try and open chrome since it may have been install in the previous step but do not error if it fails
  xdg-open "http://github.com/settings/keys" > /dev/null 2>&1

  echo "\t⏳  Press enter to continue..."
  read -r

  logDone
}

function setupGitHub() {
  setupSSHKeys
}

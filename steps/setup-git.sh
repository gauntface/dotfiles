#!/bin/bash
set -euo pipefail

function setupGitEmail() {
  git_email=$(git config --global user.email || true)

  if [[ -n $git_email ]]; then
    return
  fi

  echo "\t❓ What email address should we use for Git commits?"
  while true; do
    read -r email_addr

    if [[ -n $email_addr ]]; then
      break
    fi

    echo "\t\t🙏  Please enter an email address"
  done

  echo "\nDoes this look right? (Yes | No | Skip)"
  echo "\n\t${email_addr}\n"

  while true; do
    read -r response
    case $response in
      [Yy]* )
        git config --global user.email "${email_addr}"
        break;;
      [Nn]* )
        setupGitEmail
        break;;
      [Ss]* )
      echo "\t↪️ Skipping setup of email"
        break;;
      * )
        echo "\tPlease answer 'yes', 'no' or 'skip'."
        ;;
    esac
  done
}

function setupGit() {
  local ignore_file="${DATA_DIR}/git/global-ignore"

  echo "🖥️  Setting up Git..."
  echo "\tGit Ignore: ${ignore_file}"
  echo ""

  git config --global core.excludesfile "${ignore_file}"
  git config --global user.name "Matt Gaunt-Seo"
  git config --global pull.rebase true
  git config --global push.autoSetupRemote true

  setupGitEmail

  logDone
}

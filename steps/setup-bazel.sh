#!/bin/bash
set -euo pipefail

function setupBazelRC() {
  logTitle "🖥️  Setting up .bazelrc..."

  local bazelrc_file="${HOME}/.bazelrc"

  if [ -L "${bazelrc_file}" ] || [ -f "${bazelrc_file}" ] ; then
    rm "${bazelrc_file}"
  fi

  ln -s "${DATA_DIR}/bazel/bazelrc" "${bazelrc_file}"
  logDone
}

function setupBazel() {
  setupBazelRC
}

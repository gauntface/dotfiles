#!/bin/bash
set -euo pipefail

# ~/.claude also holds credentials, history and sessions, so link the tracked
# entries individually rather than the directory itself.
function linkClaudeEntry() {
  local src="$1"
  local dest="$2"

  if [[ -L "${dest}" ]]; then
    rm "${dest}"
  elif [[ -e "${dest}" ]]; then
    mv "${dest}" "${dest}.bak"
    echo "\t📦  Moved existing ${dest} to ${dest}.bak"
  fi

  ln -s "${src}" "${dest}"
}

function setupClaude() {
  logTitle "🤖  Setting up Claude..."

  local claude_dir="${HOME}/.claude"

  mkdir -p "${claude_dir}"

  linkClaudeEntry "${DATA_DIR}/claude/CLAUDE.md" "${claude_dir}/CLAUDE.md"
  linkClaudeEntry "${DATA_DIR}/claude/settings.json" "${claude_dir}/settings.json"
  linkClaudeEntry "${DATA_DIR}/claude/skills" "${claude_dir}/skills"

  logDone
}

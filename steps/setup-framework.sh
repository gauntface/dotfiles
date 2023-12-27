#!/bin/bash
set -euo pipefail

function setupFramework() {
  logTitle "⚡  Setting up Framework laptop..."

  sudo grubby --update-kernel=ALL --args="nvme.noacpi=1"

  logDone
}

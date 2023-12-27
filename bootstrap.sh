#!/bin/bash
set -euo pipefail

repo_url="https://github.com/gauntface/dotfiles/archive/main.tar.gz"
target_dir="$HOME/Downloads"

# Create the target directory if it doesn't exist
mkdir -p "$target_dir"

# Download the GitHub repository as a tarball and save it as repo.tar.gz
curl -L -o "$target_dir/repo.tar.gz" "$repo_url"

# Navigate to the target directory
cd "$target_dir"

# Unpack the tarball
tar -xzf repo.tar.gz

# Change directory to the unpacked repository
cd "dotfiles-main"

# Run the install.sh script if it exists
if [ -f "install.sh" ]; then
    chmod +x install.sh
    ./install.sh
else
    echo "install.sh script not found in the repository."
fi

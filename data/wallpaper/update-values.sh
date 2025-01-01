#!/bin/bash
set -euo pipefail

# Define the output directory
output_dir="${HOME}/Projects/Tools/dotfiles/data/wallpaper"

# Create the output directory if it doesn't exist
mkdir -p "$output_dir"

# Function to get and save a gsettings key
get_and_save_key() {
    local key=$1
    local filename=$2
    gsettings get org.gnome.desktop.background "$key" > "${output_dir}/${filename}"
    echo "Saved ${key} to ${output_dir}/${filename}"
}

# Get all keys for org.gnome.desktop.background
keys=$(gsettings list-keys org.gnome.desktop.background)

# Get and save all wallpaper-related settings
for key in $keys; do
    get_and_save_key "$key" "${key}.txt"
done

echo "All wallpaper settings have been saved to $output_dir"

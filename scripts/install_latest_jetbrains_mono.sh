#!/bin/bash

# Filename: install_latest_jetbrains_mono.sh
# Author: GJS (homelab-alpha)
# Date: 2024-07-05T09:20:06+02:00
# Version: 1.1.0

# Description: This script fetches the latest version of JetBrains Mono from the
# official GitHub repository, downloads it, installs it to the system-wide fonts
# directory, and cleans up the downloaded files.

# Usage: sudo ./install_latest_jetbrains_mono.sh

# Function to check if a command exists and provide installation instructions
check_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "$1 is not installed."
    echo "Please install it using your package manager:"
    echo "  - On Debian/Ubuntu: sudo apt-get install $1"
    echo "  - On Fedora based systems: sudo dnf install $1"
    echo "  - On Red Hat based systems: sudo yum install $1"
    echo "  - For other systems, visit $1's official website for installation instructions."
    exit 1
  }
}

# List of required commands
commands=("curl" "fc-cache" "unzip" "wget")

# Check for each required command and exit if any are missing
for cmd in "${commands[@]}"; do
  check_command "$cmd"
done

# Fetch the latest version of JetBrains Mono from the GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# Check if we successfully fetched the latest version
if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to fetch the latest version of JetBrains Mono."
  exit 1
fi

# Construct the download URL using the latest version
DOWNLOAD_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v${LATEST_VERSION}/JetBrainsMono-${LATEST_VERSION}.zip"

# Define the download directory
DOWNLOAD_DIR="$HOME/Downloads"

# Check if the download directory exists, if not, create it
if [ ! -d "$DOWNLOAD_DIR" ]; then
  mkdir -p "$DOWNLOAD_DIR"
  echo "Created directory: $DOWNLOAD_DIR"
fi

# Use wget to download the latest version of JetBrains Mono to the specified directory
wget -v "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip

# Check if wget successfully downloaded the file
if [ ! -f "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip ]; then
  echo "Failed to download JetBrains Mono version ${LATEST_VERSION}."
  exit 1
fi

echo "Successfully downloaded JetBrains Mono version ${LATEST_VERSION} to $DOWNLOAD_DIR."
echo ""

# Extract the downloaded zip file in the download directory
unzip "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip -d "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"

# Define the JetBrains Mono directory
JETBRAINS_MONO_DIR="/usr/share/fonts/jetbrains-mono"

# Check if the jetbrains-mono directory exists, if not, create it
if [ ! -d "$JETBRAINS_MONO_DIR" ]; then
  sudo mkdir -p "$JETBRAINS_MONO_DIR"
  echo "Created directory: $JETBRAINS_MONO_DIR"
fi

# Remove any previous installation if it exists
sudo rm -rf $JETBRAINS_MONO_DIR/*

# Move the font files to the system-wide fonts directory
sudo mv "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}/fonts/"* $JETBRAINS_MONO_DIR

# Check if the font files were successfully moved
if [ ! -f "$JETBRAINS_MONO_DIR/ttf/JetBrainsMono-Regular.ttf" ]; then
  echo "Failed to move JetBrains Mono fonts to $JETBRAINS_MONO_DIR."
  exit 1
fi

echo "Successfully installed JetBrains Mono version ${LATEST_VERSION} to $JETBRAINS_MONO_DIR."
echo ""

# Update the font cache
sudo fc-cache -f -v

# Clean up by removing the downloaded zip file and extracted directory
rm "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip
rm -r "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"

echo "Cleanup complete."
echo ""

# Verify the installation by listing the installed fonts
if ! fc-list | grep -q "JetBrains Mono"; then
  echo "JetBrains Mono font not found. Installation may have failed."
  exit 1
else
  echo "JetBrains Mono font successfully installed."
fi

#!/bin/bash

# Filename: install_latest_jetbrains_mono.sh
# Author: GJS (homelab-alpha)
# Date: 2024-07-03T14:29:36+02:00
# Version: 1.0.0

# Description: This script fetches the latest version of JetBrains Mono from the
# official GitHub repository, downloads it, installs it to the system-wide fonts
# directory, and cleans up the downloaded files.

# Usage: sudo ./install_latest_jetbrains_mono.sh

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

# Use wget to download the latest version of JetBrains Mono to the specified directory
wget -v "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip

# Check if wget successfully downloaded the file
if [ ! -f "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip ]; then
  echo "Failed to download JetBrains Mono version ${LATEST_VERSION}."
  exit 1
fi

echo "Successfully downloaded JetBrains Mono version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the downloaded zip file in the download directory
unzip "$DOWNLOAD_DIR"/JetBrainsMono-"${LATEST_VERSION}".zip -d "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"

# Create the target directory for fonts if it doesn't exist
sudo mkdir -p /usr/share/fonts/jetbrains-mono

# Move the font files to the system-wide fonts directory
sudo mv "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}/fonts/"* /usr/share/fonts/jetbrains-mono/

# Check if the font files were successfully moved
if [ ! -f "/usr/share/fonts/jetbrains-mono/ttf/JetBrainsMono-Regular.ttf" ]; then
  echo "Failed to move JetBrains Mono fonts to /usr/share/fonts/jetbrains-mono."
  exit 1
fi

echo "Successfully installed JetBrains Mono version ${LATEST_VERSION} to /usr/share/fonts/jetbrains-mono."

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

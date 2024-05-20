#!/bin/bash

# Script Name: install_latest_dart_sass.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:00+02:00
# Version: 1.1.1

# Description: This script fetches the latest version of Dart Sass from the
# official GitHub repository, downloads it, installs it to /usr/local/dart-sass,
# and cleans up the downloaded files.

# Usage: ./install_latest_dart_sass.sh

# Fetch the latest version of Dart Sass from the GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/sass/dart-sass/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Check if we successfully fetched the latest version
if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to fetch the latest version of Dart Sass."
  exit 1
fi

# Construct the download URL using the latest version
DOWNLOAD_URL="https://github.com/sass/dart-sass/releases/download/${LATEST_VERSION}/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"

# Define the download directory
DOWNLOAD_DIR="$HOME/Downloads"

# Use wget to download the latest version of Dart Sass to the specified directory
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"; then
  echo "Failed to download Dart Sass version ${LATEST_VERSION}."
  exit 1
fi

echo "Successfully downloaded Dart Sass version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the downloaded tar.gz file in the download directory
tar -xzf "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz" -C "$DOWNLOAD_DIR"

# Create the target directory if it doesn't exist
sudo mkdir -p /usr/local/dart-sass

# Remove any previous Dart Sass installation if it exists
sudo rm -rf /usr/local/dart-sass/*

# Move the extracted files to /usr/local/dart-sass
if ! sudo mv "$DOWNLOAD_DIR/dart-sass"/* /usr/local/dart-sass/; then
  echo "Failed to move Dart Sass files to /usr/local/dart-sass."
  exit 1
fi

echo "Successfully installed Dart Sass version ${LATEST_VERSION} to /usr/local/dart-sass."

# Clean up by removing the downloaded tar.gz file and the extracted directory
rm -r "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"
rm -rf "$DOWNLOAD_DIR/dart-sass"
echo "Cleanup complete."
echo ""

# Check if Sass is available and provide instructions if not
if ! command -v sass &>/dev/null; then
  echo "Sass command not found. You may need to add Dart Sass to your PATH."
  echo "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  echo ""
  echo "export PATH=\$PATH:/usr/local/dart-sass"
  echo ""
  echo "Then, run: source ~/.bashrc"
  echo "and/or"
  echo "Then, run: source ~/.bash_profile"
  exit 1
else
  echo "Sass version: $(sass --version)"
fi

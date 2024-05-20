#!/bin/bash

# Script Name: install_latest_hugo.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:08+02:00
# Version: 1.1.1

# Description: This script fetches the latest version of Hugo from the official
# GitHub repository, downloads it, installs it to /usr/local/hugo-extended, and
# cleans up the downloaded files.

# Usage: ./install_latest_hugo.sh

# Fetch the latest version of Hugo from the GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# Check if we successfully fetched the latest version
if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to fetch the latest version of Hugo."
  exit 1
fi

# Construct the download URL using the latest version
DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${LATEST_VERSION}/hugo_extended_${LATEST_VERSION}_linux-amd64.tar.gz"

# Define the download directory
DOWNLOAD_DIR="$HOME/Downloads"

# Use wget to download the latest version of Hugo to the specified directory
wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR"/hugo_extended_"${LATEST_VERSION}"_linux-amd64.tar.gz

# Check if wget successfully downloaded the file
if ! wget -q --spider "$DOWNLOAD_URL"; then
  echo "Failed to download Hugo version ${LATEST_VERSION}."
  exit 1
fi

echo "Successfully downloaded Hugo version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the downloaded tar.gz file in the download directory
tar -xzf "$DOWNLOAD_DIR"/hugo_extended_"${LATEST_VERSION}"_linux-amd64.tar.gz -C "$DOWNLOAD_DIR"

# Create the target directory if it doesn't exist
sudo mkdir -p /usr/local/hugo-extended

# Remove any previous Hugo installation if it exists
sudo rm -rf /usr/local/hugo-extended/*

# Move the Hugo binary and additional files to /usr/local/hugo-extended
sudo mv "$DOWNLOAD_DIR"/hugo /usr/local/hugo-extended/
sudo mv "$DOWNLOAD_DIR"/LICENSE /usr/local/hugo-extended/
sudo mv "$DOWNLOAD_DIR"/README.md /usr/local/hugo-extended/

# Check if the Hugo binary was successfully moved
if [ ! -f "/usr/local/hugo-extended/hugo" ]; then
  echo "Failed to move Hugo binary to /usr/local/hugo-extended."
  exit 1
fi

echo "Successfully installed Hugo version ${LATEST_VERSION} to /usr/local/hugo-extended."

# Clean up by removing the downloaded tar.gz file
rm "$DOWNLOAD_DIR"/hugo_extended_"${LATEST_VERSION}"_linux-amd64.tar.gz

echo "Cleanup complete."
echo ""

# Check if Hugo is available and provide instructions if not
if ! command -v hugo &>/dev/null; then
  echo "Hugo command not found. You may need to add Go to your PATH."
  echo "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  echo ""
  echo "export PATH=\$PATH:/usr/local/hugo-extended"
  echo ""
  echo "Then, run: source ~/.bashrc"
  echo "Or"
  echo "Then, run: source ~/.bash_profile"
  exit 1
else
  echo "Hugo version: $(hugo version)"
fi

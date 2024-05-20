#!/bin/bash

# Script Name: install_latest_go.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:02+02:00
# Version: 1.1.1

# Description: This script fetches the latest version of Go from the official Go
# download page, downloads it, installs it to /usr/local/go, and cleans up the
# downloaded files.

# Usage: ./install_latest_go.sh

# Fetch the latest version of Go from the official download page
LATEST_VERSION_OUTPUT=$(curl -s https://go.dev/VERSION?m=text)

# Extract the version number from the output
LATEST_VERSION="$(echo $LATEST_VERSION_OUTPUT | awk '{print $1}' | sed 's/go//')"

# Check if we successfully fetched the latest version
if [ -z "$LATEST_VERSION" ]; then
  echo "Failed to fetch the latest version of Go."
  exit 1
fi

# Construct the download URL using the latest version
DOWNLOAD_URL="https://go.dev/dl/go${LATEST_VERSION}.linux-amd64.tar.gz"

# Define the download directory
DOWNLOAD_DIR="$HOME/Downloads"

# Use wget to download the latest version of Go to the specified directory
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz"; then
  echo "Failed to download Go version ${LATEST_VERSION}."
  exit 1
fi

echo "Successfully downloaded Go version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the downloaded tar.gz file in the download directory
tar -xzf "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz" -C "$DOWNLOAD_DIR"

# Create the target directory if it doesn't exist
sudo mkdir -p /usr/local/go

# Remove any previous Go installation if it exists
sudo rm -rf /usr/local/go

# Move the extracted files to /usr/local/go
if ! sudo mv "$DOWNLOAD_DIR/go" /usr/local/; then
  echo "Failed to move Go files to /usr/local/go."
  exit 1
fi

echo "Successfully installed Go version ${LATEST_VERSION} to /usr/local/go."

# Clean up by removing the downloaded tar.gz file
rm "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz"
echo "Cleanup complete."
echo ""

# Check if Go is available and provide instructions if not
if ! command -v go &>/dev/null; then
  echo "Go command not found. You may need to add Go to your PATH."
  echo "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  echo ""
  echo "export PATH=\$PATH:/usr/local/go/bin"
  echo ""
  echo "Then, run: source ~/.bashrc"
  echo "and/or"
  echo "Then, run: source ~/.bash_profile"
  exit 1
else
  echo "Go version: $(go version)"
fi

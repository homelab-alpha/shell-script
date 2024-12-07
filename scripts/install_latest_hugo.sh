#!/bin/bash

# Filename: install_latest_hugo.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-07T14:32:39+01:00
# Version: 1.1.1

# Description: This script fetches the latest version of Hugo from the official
# GitHub repository, downloads it, installs it to /usr/local/hugo-extended, and
# cleans up the downloaded files.

# Usage: ./install_latest_hugo.sh

# Define log directory and log file
LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_hugo.log"

# Function to log informational messages with timestamp
log() {
  local TIMESTAMP
  TIMESTAMP=$(date +"%b %d, %Y %H:%M:%S")
  echo "$TIMESTAMP [INFO] - $1" | tee -a "$LOG_FILE"
}

# Function to log error messages with timestamp.
log_error() {
  local TIMESTAMP
  TIMESTAMP=$(date +"%b %d, %Y %H:%M:%S")
  echo "$TIMESTAMP [ERROR] - $1" | tee -a "$LOG_FILE"
}

# Start the script execution
log "Script execution started."

# Checking if Hugo is already installed, and log the current version if present
log "Checking current installed version of Hugo (if available)..."
if command -v sass &>/dev/null; then
  log "Hugo version: $(hugo version)"
else
  log "Hugo is not currently installed."
fi

# Fetching the latest release version of Hugo from the GitHub API
log "Fetching the latest version of Hugo from the GitHub API..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# If the version can't be fetched, exit the script with an error
if [ -z "$LATEST_VERSION" ]; then
  log_error "Failed to fetch the latest version of Hugo. Exiting."
  exit 1
fi
log "Latest version of Hugo: $LATEST_VERSION"

# Constructing the download URL for the latest Hugo release
DOWNLOAD_URL="https://github.com/gohugoio/hugo/releases/download/v${LATEST_VERSION}/hugo_extended_${LATEST_VERSION}_linux-amd64.tar.gz"
log "Constructed download URL: $DOWNLOAD_URL"

# Defining the directory for downloading the Hugo package
DOWNLOAD_DIR="$HOME/Downloads"
log "Download directory: $DOWNLOAD_DIR"

# Downloading the Hugo tarball from the GitHub release URL
log "Downloading Hugo version ${LATEST_VERSION}..."
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/hugo_extended_${LATEST_VERSION}_linux-amd64.tar.gz"; then
  log_error "Failed to download Hugo version ${LATEST_VERSION}. Exiting."
  exit 1
fi
log "Successfully downloaded Hugo version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extracting the Hugo tarball into the download directory
log "Extracting Hugo files..."
tar -xzf "$DOWNLOAD_DIR/hugo_extended_${LATEST_VERSION}_linux-amd64.tar.gz" -C "$DOWNLOAD_DIR"

# Ensuring the target directory /usr/local/hugo-extended exists
log "Ensuring target directory exists: /usr/local/hugo-extended"
sudo mkdir -p /usr/local/hugo-extended

# Removing any existing Hugo installation in /usr/local/hugo-extended
log "Removing any existing Hugo installation in /usr/local/hugo-extended..."
sudo rm -rf /usr/local/hugo-extended/*

# Moving the Hugo binary and related files to the target installation directory
log "Installing Hugo to /usr/local/hugo-extended..."
sudo mv "$DOWNLOAD_DIR/hugo" /usr/local/hugo-extended/
sudo mv "$DOWNLOAD_DIR/LICENSE" /usr/local/hugo-extended/
sudo mv "$DOWNLOAD_DIR/README.md" /usr/local/hugo-extended/

# If the Hugo binary isn't found in the target directory, log an error and exit
if [ ! -f "/usr/local/hugo-extended/hugo" ]; then
  log_error "Failed to move Hugo binary to /usr/local/hugo-extended. Exiting."
  exit 1
fi
log "Hugo version ${LATEST_VERSION} installed successfully to /usr/local/hugo-extended."

# Clean up the downloaded tarball
log "Cleaning up temporary files..."
rm "$DOWNLOAD_DIR/hugo_extended_${LATEST_VERSION}_linux-amd64.tar.gz"
log "Cleanup complete."

# Verifying that the Hugo command is available after installation
if ! command -v hugo &>/dev/null; then
  log_error "Hugo command not found. You may need to add Hugo to your PATH."
  log_error "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  log_error "export PATH=\$PATH:/usr/local/hugo-extended"
  exit 1
else
  log "Verification: Hugo is installed and available."
  log "Hugo version: $(hugo version)"
fi

# End the logging process
log "Script execution completed."

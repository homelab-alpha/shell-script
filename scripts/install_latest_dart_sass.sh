#!/bin/bash

# Filename: install_latest_dart_sass.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-07T12:05:33+01:00
# Version: 1.1.0

# Description: This script fetches the latest version of Dart Sass from the
# official GitHub repository, downloads it, installs it to /usr/local/dart-sass,
# and cleans up the downloaded files.

# Usage: ./install_latest_dart_sass.sh

LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_dart_sass.log"

log() {
  local TIMESTAMP
  TIMESTAMP=$(date +"%b %d, %Y %H:%M:%S")
  echo "$TIMESTAMP [INFO] - $1" | tee -a "$LOG_FILE"
}

log_error() {
  local TIMESTAMP
  TIMESTAMP=$(date +"%b %d, %Y %H:%M:%S")
  echo "$TIMESTAMP [ERROR] - $1" | tee -a "$LOG_FILE"
}

log "Script execution started."

log "Checking current installed version of Sass (if available)..."
if command -v sass &>/dev/null; then
  log "Sass version: $(sass --version)"
else
  log "Sass is not currently installed."
fi

log "Fetching the latest version of Dart Sass from the GitHub API..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/sass/dart-sass/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
  log_error "Unable to fetch the latest version of Dart Sass. Exiting."
  exit 1
fi
log "Latest version of Dart Sass: $LATEST_VERSION"

DOWNLOAD_URL="https://github.com/sass/dart-sass/releases/download/${LATEST_VERSION}/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"
log "Constructed download URL: $DOWNLOAD_URL"

DOWNLOAD_DIR="$HOME/Downloads"
log "Download directory: $DOWNLOAD_DIR"

log "Downloading Dart Sass version ${LATEST_VERSION}..."
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"; then
  log_error "Failed to download Dart Sass version ${LATEST_VERSION}. Exiting."
  exit 1
fi
log "Successfully downloaded Dart Sass version ${LATEST_VERSION} to $DOWNLOAD_DIR."

log "Extracting Dart Sass files..."
tar -xzf "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz" -C "$DOWNLOAD_DIR"

log "Ensuring target directory exists: /usr/local/dart-sass"
sudo mkdir -p /usr/local/dart-sass

log "Removing any existing Dart Sass installation in /usr/local/dart-sass..."
sudo rm -rf /usr/local/dart-sass/*

log "Installing Dart Sass to /usr/local/dart-sass..."
if ! sudo mv "$DOWNLOAD_DIR/dart-sass"/* /usr/local/dart-sass/; then
  log_error "Failed to move Dart Sass files to /usr/local/dart-sass. Exiting."
  exit 1
fi
log "Dart Sass version ${LATEST_VERSION} installed successfully."

log "Cleaning up temporary files..."
rm -r "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"
rm -rf "$DOWNLOAD_DIR/dart-sass"
log "Cleanup complete."

if ! command -v sass &>/dev/null; then
  log_error "Sass command not found. You may need to add Dart Sass to your PATH."
  log_error "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  log_error "export PATH=\$PATH:/usr/local/dart-sass"
  exit 1
else
  log "Verification: Sass is installed and available."
  log "Sass version: $(sass --version)"
fi

log "Script execution completed."

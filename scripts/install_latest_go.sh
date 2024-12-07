#!/bin/bash

# Filename: install_latest_go.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-07T12:05:31+01:00
# Version: 1.1.0

# Description: This script fetches the latest version of Go from the official Go
# download page, downloads it, installs it to /usr/local/go, and cleans up the
# downloaded files.

# Usage: ./install_latest_go.sh

LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_go.log"

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

log "Checking current installed version of Go (if available)..."
if command -v sass &>/dev/null; then
  log "Go version: $(go version)"
else
  log "Go is not currently installed."
fi

log "Fetching the latest version of Go from the official download page..."
LATEST_VERSION_OUTPUT=$(curl -s https://go.dev/VERSION?m=text)

LATEST_VERSION="$(echo $LATEST_VERSION_OUTPUT | awk '{print $1}' | sed 's/go//')"

if [ -z "$LATEST_VERSION" ]; then
  log_error "Failed to fetch the latest version of Go. Exiting."
  exit 1
fi
log "Latest version of Go: $LATEST_VERSION"

DOWNLOAD_URL="https://go.dev/dl/go${LATEST_VERSION}.linux-amd64.tar.gz"
log "Constructed download URL: $DOWNLOAD_URL"

DOWNLOAD_DIR="$HOME/Downloads"
log "Download directory: $DOWNLOAD_DIR"

log "Downloading Go version ${LATEST_VERSION}..."
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz"; then
  log_error "Failed to download Go version ${LATEST_VERSION}. Exiting."
  exit 1
fi
log "Successfully downloaded Go version ${LATEST_VERSION} to $DOWNLOAD_DIR."

log "Extracting Go files..."
tar -xzf "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz" -C "$DOWNLOAD_DIR"

log "Ensuring target directory exists: /usr/local/go"
sudo mkdir -p /usr/local/go

log "Removing any existing Go installation in /usr/local/go..."
sudo rm -rf /usr/local/go

log "Installing Go to /usr/local/go..."
if ! sudo mv "$DOWNLOAD_DIR/go" /usr/local/; then
  log_error "Failed to move Go files to /usr/local/go. Exiting."
  exit 1
fi
log "Go version ${LATEST_VERSION} installed successfully to /usr/local/go."

log "Cleaning up temporary files..."
rm "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz"
log "Cleanup complete."

if ! command -v go &>/dev/null; then
  log_error "Go command not found. You may need to add Go to your PATH."
  log_error "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  log_error "export PATH=\$PATH:/usr/local/go/bin"
  exit 1
else
  log "Verification: Go is installed and available."
  log "Go version: $(go version)"
fi

log "Script execution completed."

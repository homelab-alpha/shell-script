#!/bin/bash

# Filename: install_latest_go.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-07T14:33:21+01:00
# Version: 1.1.1

# Description: This script fetches the latest version of Go from the official Go
# download page, downloads it, installs it to /usr/local/go, and cleans up the
# downloaded files.

# Usage: ./install_latest_go.sh

# Define log directory and log file
LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_go.log"

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

# Check if Go is already installed and display the version if found
log "Checking current installed version of Go (if available)..."
if command -v go &>/dev/null; then
  log "Go version: $(go version)"
else
  log "Go is not currently installed."
fi

# Fetch the latest stable version of Go from the official website
log "Fetching the latest version of Go from the official download page..."
LATEST_VERSION_OUTPUT=$(curl -s https://go.dev/VERSION?m=text)

# Extract the version number from the output and remove the 'go' prefix
LATEST_VERSION="$(echo $LATEST_VERSION_OUTPUT | awk '{print $1}' | sed 's/go//')"

# If the version cannot be determined, log an error and exit
if [ -z "$LATEST_VERSION" ]; then
  log_error "Failed to fetch the latest version of Go. Exiting."
  exit 1
fi
log "Latest version of Go: $LATEST_VERSION"

# Construct the download URL for the latest Go tarball
DOWNLOAD_URL="https://go.dev/dl/go${LATEST_VERSION}.linux-amd64.tar.gz"
log "Constructed download URL: $DOWNLOAD_URL"

# Set the directory where the tarball will be downloaded
DOWNLOAD_DIR="$HOME/Downloads"
log "Download directory: $DOWNLOAD_DIR"

# Download the Go tarball for the latest version
log "Downloading Go version ${LATEST_VERSION}..."
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz"; then
  log_error "Failed to download Go version ${LATEST_VERSION}. Exiting."
  exit 1
fi
log "Successfully downloaded Go version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the tarball to the download directory
log "Extracting Go files..."
tar -xzf "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz" -C "$DOWNLOAD_DIR"

# Ensure the target directory for installation exists
log "Ensuring target directory exists: /usr/local/go"
sudo mkdir -p /usr/local/go

# Remove any existing Go installation in the target directory
log "Removing any existing Go installation in /usr/local/go..."
sudo rm -rf /usr/local/go

# Move the extracted Go directory to the installation path
log "Installing Go to /usr/local/go..."
if ! sudo mv "$DOWNLOAD_DIR/go" /usr/local/; then
  log_error "Failed to move Go files to /usr/local/go. Exiting."
  exit 1
fi
log "Go version ${LATEST_VERSION} installed successfully to /usr/local/go."

# Clean up the downloaded tarball after installation
log "Cleaning up temporary files..."
rm "$DOWNLOAD_DIR/go${LATEST_VERSION}.linux-amd64.tar.gz"
log "Cleanup complete."

# Verify if Go was installed successfully and is available in the PATH
if ! command -v go &>/dev/null; then
  log_error "Go command not found. You may need to add Go to your PATH."
  log_error "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  log_error "export PATH=\$PATH:/usr/local/go/bin"
  exit 1
else
  log "Verification: Go is installed and available."
  log "Go version: $(go version)"
fi

# End the logging process
log "Script execution completed."

#!/bin/bash

# Filename: install_latest_protoc.sh
# Author: GJS (homelab-alpha)
# Date: 2025-05-09T10:21:23+02:00
# Version: 1.0.0

# Description: This script fetches the latest version of protoc (Protocol Buffers) from the
# official GitHub repository, downloads it, installs it to /usr/local/protoc,
# and cleans up the downloaded files.

# Usage: ./install_latest_protoc.sh

# Define log directory and log file
LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_protoc.log"

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

# Start logging the execution
log "─────────────────────────────────────────────────"
log "Script execution started."

# Check if Protoc is already installed and log the current version
log "Checking current installed version of Protoc (if available)..."
if command -v protoc &>/dev/null; then
  log "Protoc version: $(protoc --version)"
else
  log "Protoc is not currently installed."
fi

# Fetch the latest release version of Protoc from the GitHub API
log "Fetching the latest version of Protoc from the GitHub API..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/protocolbuffers/protobuf/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Exit if the version could not be fetched
if [ -z "$LATEST_VERSION" ]; then
  log_error "Unable to fetch the latest version of Protoc. Exiting."
  exit 1
fi
log "Latest version of Protoc: $LATEST_VERSION"

# Construct the download URL based on the latest version
DOWNLOAD_URL="https://github.com/protocolbuffers/protobuf/releases/download/${LATEST_VERSION}/protoc-${LATEST_VERSION#v}-linux-x86_64.zip"
log "Constructed download URL: $DOWNLOAD_URL"

# Define the directory where the downloaded file will be saved
DOWNLOAD_DIR="$HOME/Downloads"
log "Download directory: $DOWNLOAD_DIR"

# Download the Protoc zip to the specified directory
log "Downloading Protoc version ${LATEST_VERSION}..."
echo
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/protoc-${LATEST_VERSION}-linux-x86_64.zip"; then
  log_error "Failed to download Protoc version ${LATEST_VERSION}. Exiting."
  exit 1
fi
echo
log "Successfully downloaded Protoc version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the downloaded zip
log "Extracting Protoc files..."
unzip -o "$DOWNLOAD_DIR/protoc-${LATEST_VERSION}-linux-x86_64.zip" -d "$DOWNLOAD_DIR/protoc"
echo

# Ensure that the target installation directory exists
log "Ensuring target directory exists: /usr/local/protoc"
sudo mkdir -p /usr/local/protoc

# Remove any existing installation in the target directory to avoid conflicts
log "Removing any existing Protoc installation in /usr/local/protoc..."
sudo rm -rf /usr/local/protoc/*

# Install Protoc by moving the extracted files to the target directory
log "Installing Protoc to /usr/local/protoc..."
if ! sudo mv "$DOWNLOAD_DIR/protoc"/* /usr/local/protoc/; then
  log_error "Failed to move Protoc files to /usr/local/protoc. Exiting."
  exit 1
fi
log "Protoc version ${LATEST_VERSION} installed successfully."

# Clean up the temporary files after installation
log "Cleaning up temporary files..."
rm -r "$DOWNLOAD_DIR/protoc-${LATEST_VERSION}-linux-x86_64.zip"
rm -rf "$DOWNLOAD_DIR/protoc"
log "Cleanup complete."

# Verify if Protoc is accessible after installation
if ! command -v protoc &>/dev/null; then
  log_error "Protoc command not found. You may need to add Protoc to your PATH."
  log_error "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  log_error "export PATH=\$PATH:/usr/local/protoc/bin"
  exit 1
else
  log "Verification: Protoc is installed and available."
  log "Protoc version: $(protoc --version)"
fi

# End the logging process
log "Script execution completed."

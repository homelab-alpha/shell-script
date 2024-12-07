#!/bin/bash

# Filename: install_latest_dart_sass.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-07T14:34:33+01:00
# Version: 1.1.1

# Description: This script fetches the latest version of Dart Sass from the
# official GitHub repository, downloads it, installs it to /usr/local/dart-sass,
# and cleans up the downloaded files.

# Usage: ./install_latest_dart_sass.sh

# Define log directory and log file
LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_dart_sass.log"

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
log "Script execution started."

# Check if Sass is already installed and log the current version
log "Checking current installed version of Sass (if available)..."
if command -v sass &>/dev/null; then
  log "Sass version: $(sass --version)"
else
  log "Sass is not currently installed."
fi

# Fetch the latest release version of Dart Sass from the GitHub API
log "Fetching the latest version of Dart Sass from the GitHub API..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/sass/dart-sass/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Exit if the version could not be fetched
if [ -z "$LATEST_VERSION" ]; then
  log_error "Unable to fetch the latest version of Dart Sass. Exiting."
  exit 1
fi
log "Latest version of Dart Sass: $LATEST_VERSION"

# Construct the download URL based on the latest version
DOWNLOAD_URL="https://github.com/sass/dart-sass/releases/download/${LATEST_VERSION}/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"
log "Constructed download URL: $DOWNLOAD_URL"

# Define the directory where the downloaded file will be saved
DOWNLOAD_DIR="$HOME/Downloads"
log "Download directory: $DOWNLOAD_DIR"

# Download the Dart Sass tarball to the specified directory
log "Downloading Dart Sass version ${LATEST_VERSION}..."
if ! wget "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"; then
  log_error "Failed to download Dart Sass version ${LATEST_VERSION}. Exiting."
  exit 1
fi
log "Successfully downloaded Dart Sass version ${LATEST_VERSION} to $DOWNLOAD_DIR."

# Extract the downloaded tarball
log "Extracting Dart Sass files..."
tar -xzf "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz" -C "$DOWNLOAD_DIR"

# Ensure that the target installation directory exists
log "Ensuring target directory exists: /usr/local/dart-sass"
sudo mkdir -p /usr/local/dart-sass

# Remove any existing installation in the target directory to avoid conflicts
log "Removing any existing Dart Sass installation in /usr/local/dart-sass..."
sudo rm -rf /usr/local/dart-sass/*

# Install Dart Sass by moving the extracted files to the target directory
log "Installing Dart Sass to /usr/local/dart-sass..."
if ! sudo mv "$DOWNLOAD_DIR/dart-sass"/* /usr/local/dart-sass/; then
  log_error "Failed to move Dart Sass files to /usr/local/dart-sass. Exiting."
  exit 1
fi
log "Dart Sass version ${LATEST_VERSION} installed successfully."

# Clean up the temporary files after installation
log "Cleaning up temporary files..."
rm -r "$DOWNLOAD_DIR/dart-sass-${LATEST_VERSION}-linux-x64.tar.gz"
rm -rf "$DOWNLOAD_DIR/dart-sass"
log "Cleanup complete."

# Verify if Sass is accessible after installation
if ! command -v sass &>/dev/null; then
  log_error "Sass command not found. You may need to add Dart Sass to your PATH."
  log_error "To do this, add the following line to your ~/.bashrc or ~/.bash_profile:"
  log_error "export PATH=\$PATH:/usr/local/dart-sass"
  exit 1
else
  log "Verification: Sass is installed and available."
  log "Sass version: $(sass --version)"
fi

# End the logging process
log "Script execution completed."

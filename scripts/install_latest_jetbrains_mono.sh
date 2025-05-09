#!/bin/bash

# Filename: install_latest_jetbrains_mono.sh
# Author: GJS (homelab-alpha)
# Date: 2025-05-09T10:21:54+02:00
# Version: 1.1.2

# Description: This script fetches the latest version of JetBrains Mono from the
# official GitHub repository, downloads it, installs it to the system-wide fonts
# directory, and cleans up the downloaded files.

# Usage: sudo ./install_latest_jetbrains_mono.sh

# Define log directory and log file
LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_jetbrains_mono.log"

# Function to log informational messages with timestamp
log() {
  local TIMESTAMP
  TIMESTAMP=$(date +"%b %d, %Y %H:%M:%S")
  echo "$TIMESTAMP [INFO] - $1" | tee -a "$LOG_FILE"
}

# Function to log error messages with timestamp.
log_error() {
  local TIMESTAMP
  TIMESTAMP=$(date +"%b %b %d, %Y %H:%M:%S")
  echo "$TIMESTAMP [ERROR] - $1" | tee -a "$LOG_FILE"
}

# Start the script execution
log "─────────────────────────────────────────────────"
log "Script execution started."

# Function to check if a command is available in the system.
check_command() {
  command -v "$1" >/dev/null 2>&1 || {
    log_error "$1 is not installed. Please install it using your package manager."
    exit 1
  }
}

# List of required commands for the script to function properly.
commands=("curl" "fc-cache" "unzip" "wget")

# Loop through each required command and verify if it is installed.
for cmd in "${commands[@]}"; do
  log "Checking for required command: $cmd"
  check_command "$cmd"
done

# Fetch the latest release version of JetBrains Mono from GitHub API.
log "Fetching the latest version of JetBrains Mono from GitHub..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# If the version is not fetched successfully, exit the script.
if [ -z "$LATEST_VERSION" ]; then
  log_error "Failed to fetch the latest version of JetBrains Mono. Exiting."
  exit 1
fi
log "Latest version of JetBrains Mono: $LATEST_VERSION"

# Set the download URL and directories for storing the font files.
DOWNLOAD_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v${LATEST_VERSION}/JetBrainsMono-${LATEST_VERSION}.zip"
DOWNLOAD_DIR="$HOME/Downloads"
JETBRAINS_MONO_DIR="/usr/share/fonts/jetbrains-mono"

# Ensure that the download directory exists before starting the download.
log "Ensuring download directory exists: $DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR"

# Download the latest version of JetBrains Mono font from GitHub.
log "Downloading JetBrains Mono version ${LATEST_VERSION}..."
echo
if ! wget -v "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}.zip"; then
  log_error "Failed to download JetBrains Mono version ${LATEST_VERSION}. Exiting."
  exit 1
fi
echo
log "Successfully downloaded JetBrains Mono to $DOWNLOAD_DIR."

# Extract the downloaded zip file to the appropriate directory.
log "Extracting JetBrains Mono zip file..."
unzip "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}.zip" -d "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"
echo

# Ensure that the target font directory exists before installation.
log "Ensuring target font directory exists: $JETBRAINS_MONO_DIR"
sudo mkdir -p "$JETBRAINS_MONO_DIR"

# Remove any previous installations of JetBrains Mono from the target font directory.
log "Removing any previous JetBrains Mono installation..."
sudo rm -rf "$JETBRAINS_MONO_DIR"/*

# Move the newly downloaded fonts to the target font directory.
log "Installing fonts to $JETBRAINS_MONO_DIR..."
sudo mv "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}/fonts/"* "$JETBRAINS_MONO_DIR"

# Verify that the font file has been successfully moved. If not, exit the script.
if [ ! -f "$JETBRAINS_MONO_DIR/ttf/JetBrainsMono-Regular.ttf" ]; then
  log_error "Failed to move JetBrains Mono fonts to $JETBRAINS_MONO_DIR. Exiting."
  exit 1
fi
log "Fonts installed successfully."

# Update the font cache to make the newly installed fonts available system-wide.
log "Updating font cache..."
sudo fc-cache -f -v

# Clean up temporary files (downloaded zip and extracted folder).
log "Cleaning up temporary files..."
rm "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}.zip"
rm -r "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"

# Verify if the font was successfully installed by checking if it is listed in the system's font cache.
log "Verifying installation..."
if ! fc-list | grep -q "JetBrains Mono"; then
  log_error "JetBrains Mono font not found. Installation may have failed."
  exit 1
fi
log "JetBrains Mono font installed successfully."

# End the logging process
log "Script execution completed."

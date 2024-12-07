#!/bin/bash

# Filename: install_latest_jetbrains_mono.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-07T12:05:25+01:00
# Version: 1.1.0

# Description: This script fetches the latest version of JetBrains Mono from the
# official GitHub repository, downloads it, installs it to the system-wide fonts
# directory, and cleans up the downloaded files.

# Usage: sudo ./install_latest_jetbrains_mono.sh

LOG_DIR="$HOME/.bash-script"
LOG_FILE="$LOG_DIR/install_latest_jetbrains_mono.log"

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

check_command() {
  command -v "$1" >/dev/null 2>&1 || {
    log_error "$1 is not installed. Please install it using your package manager."
    exit 1
  }
}

commands=("curl" "fc-cache" "unzip" "wget")

for cmd in "${commands[@]}"; do
  log "Checking for required command: $cmd"
  check_command "$cmd"
done

log "Fetching the latest version of JetBrains Mono from GitHub..."
LATEST_VERSION=$(curl -s https://api.github.com/repos/JetBrains/JetBrainsMono/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

if [ -z "$LATEST_VERSION" ]; then
  log_error "Failed to fetch the latest version of JetBrains Mono. Exiting."
  exit 1
fi
log "Latest version of JetBrains Mono: $LATEST_VERSION"

DOWNLOAD_URL="https://github.com/JetBrains/JetBrainsMono/releases/download/v${LATEST_VERSION}/JetBrainsMono-${LATEST_VERSION}.zip"
DOWNLOAD_DIR="$HOME/Downloads"
JETBRAINS_MONO_DIR="/usr/share/fonts/jetbrains-mono"

log "Ensuring download directory exists: $DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR"

log "Downloading JetBrains Mono version ${LATEST_VERSION}..."
if ! wget -v "$DOWNLOAD_URL" -O "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}.zip"; then
  log_error "Failed to download JetBrains Mono version ${LATEST_VERSION}. Exiting."
  exit 1
fi
log "Successfully downloaded JetBrains Mono to $DOWNLOAD_DIR."

log "Extracting JetBrains Mono zip file..."
unzip "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}.zip" -d "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"

log "Ensuring target font directory exists: $JETBRAINS_MONO_DIR"
sudo mkdir -p "$JETBRAINS_MONO_DIR"

log "Removing any previous JetBrains Mono installation..."
sudo rm -rf "$JETBRAINS_MONO_DIR"/*

log "Installing fonts to $JETBRAINS_MONO_DIR..."
sudo mv "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}/fonts/"* "$JETBRAINS_MONO_DIR"

if [ ! -f "$JETBRAINS_MONO_DIR/ttf/JetBrainsMono-Regular.ttf" ]; then
  log_error "Failed to move JetBrains Mono fonts to $JETBRAINS_MONO_DIR. Exiting."
  exit 1
fi
log "Fonts installed successfully."

log "Updating font cache..."
sudo fc-cache -f -v

log "Cleaning up temporary files..."
rm "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}.zip"
rm -r "$DOWNLOAD_DIR/JetBrainsMono-${LATEST_VERSION}"

log "Verifying installation..."
if ! fc-list | grep -q "JetBrains Mono"; then
  log_error "JetBrains Mono font not found. Installation may have failed."
  exit 1
fi
log "JetBrains Mono font installed successfully."

log "Script execution completed."

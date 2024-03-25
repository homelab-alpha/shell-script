#!/bin/bash

# Script: targzip.sh
# Description: This script creates a tar archive of a directory or file and compresses it using gzip.
# Author: GJS (homelab-alpha)
# Date: 2024-03-13T07:38:26Z

# Function: targzip
# Usage: targzip <directory or file>
# This function takes a directory or file as input and creates a tar archive of it.
# Then, it compresses the tar archive using gzip. The resulting compressed file is named with a timestamp.
# If successful, it outputs a message indicating the successful creation and verification of the compressed file.

function targzip() {
  local source
  source="$1"
  local timestamp
  timestamp=$(date +'%b %d, %Y - %H%M%S')
  local tmpFile
  tmpFile="${source%/} [$timestamp].tar"
  local compressedFile
  compressedFile="$tmpFile.gz"

  # Create tar archive
  tar --create --file="$tmpFile" --verify --verbose "$source" || return 1

  # Determine the correct 'stat' command for the platform
  local size
  if stat --version &>/dev/null; then
    size=$(stat -c%s "$tmpFile")
  elif stat -f%z "$tmpFile" &>/dev/null; then
    size=$(stat -f%z "$tmpFile")
  else
    echo "Error: Unable to determine file size."
    return 1
  fi

  echo "Size of $tmpFile: $size bytes"

  local cmd="gzip"

  # Compress tar archive using gzip
  echo ""
  echo "Compressing .tar using $cmd."
  $cmd "$tmpFile" --best --rsyncable --verbose || return 1
  [ -f "$tmpFile" ] && rm "$tmpFile"

  # Verify the integrity of the compressed file
  echo ""
  echo "Verifying $compressedFile using $cmd."
  $cmd -t "$compressedFile" --verbose || return 1

  echo ""
  echo "$compressedFile has been successfully created and verified."
  chmod 644 "$compressedFile"
}

# Call the targzip function with the provided argument
targzip "$1"

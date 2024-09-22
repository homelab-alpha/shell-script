#!/bin/bash

# Filename: tarzip.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-26T11:59:24+02:00
# Version: 1.0

# Description: This script creates a compressed archive (.zip) of a specified
# folder using tar and zip commands.

# Usage: tarzip <directory or file>

# Function: tarzip
# This function takes a directory or file as input and creates a tar archive of
# it. Then, it compresses the tar archive using gzip. The resulting compressed
# file is named with a timestamp. If successful, it outputs a message indicating
# the successful creation and verification of the compressed file.

function tarzip() {
  local input_folder
  input_folder="$1"

  # Input validation
  if [ $# -ne 1 ]; then
    echo "Usage: tarzip <folder>"
    return 1
  fi

  if [ ! -d "$input_folder" ]; then
    echo "Error: '$input_folder' is not a valid directory."
    return 1
  fi

  local timestamp
  timestamp="$(date +'%b %d, %Y - %H%M%S')"

  local tmp_file
  tmp_file="${input_folder%/} [$timestamp].tar"

  local zip_file
  zip_file="${input_folder%/} [$timestamp].tar.zip"

  echo "Creating .tar archive for $input_folder..."
  tar --create --file="$tmp_file" --verbose "$input_folder" || return 1

  local size
  size=$(stat -c "%s" "$tmp_file" 2>/dev/null)
  [ -z "$size" ] && size=$(stat -f "%z" "$tmp_file" 2>/dev/null)

  local cmd="zip"
  echo ""
  echo "Compressing .tar using $cmd..."
  $cmd "$zip_file" --encrypt --recurse-paths -9 --verbose "$tmp_file" || return 1

  if [ -f "$tmp_file" ]; then
    rm "$tmp_file"
  fi

  echo ""
  echo "Verifying $zip_file using $cmd..."
  $cmd "$zip_file" --test --verbose || return 1

  echo ""
  echo "$zip_file has been successfully created and verified."
  chmod 644 "$zip_file"
}

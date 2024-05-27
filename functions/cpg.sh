#!/bin/bash

# Script Name: cpg.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-26T11:59:55+02:00
# Version: 1.0.1

# Description: This script provides a function 'cpg' to copy files or
# directories from a source to a destination. It handles both single files and
# directories, including recursive copying.

# Usage: cpg source destination
#   - source: The file or directory to be copied.
#   - destination: The location where the source will be copied.

# Function: cpg

function cpg() {
  # Check if the number of arguments is not equal to 2
  if [ $# -ne 2 ]; then
    echo "Usage: cpg source destination"  # Print usage information
    return 1  # Return error status
  fi

  local source="$1"  # Assign the first argument to the source variable
  local destination="$2"  # Assign the second argument to the destination variable

  # Check if the source is a directory
  if [ -d "$source" ]; then
    # Check if the destination is also a directory
    if [ -d "$destination" ]; then
      # Copy the source directory to the destination directory recursively
      # Change directory to the copied directory in the destination
      cp -r "$source" "$destination" && cd "$destination/$(basename "$source")" || exit
    else
      echo "Destination is not a directory: $destination"  # Print error message
      return 1  # Return error status
    fi
  else
    cp "$source" "$destination"  # Copy the source file to the destination
  fi
}

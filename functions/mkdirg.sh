#!/bin/bash

# Script Name: mkdirg.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-26T11:59:35+02:00
# Version: 1.0.1

# Description: This script creates a directory if it doesn't exist and navigates
# into it.

# Function: mkdirg
# Parameters:
#   $1: The name of the directory to create.
# Returns:
#   0 if successful, 1 otherwise.

# Function to make directory and navigate into it
function mkdirg() {
  # Check if the correct number of arguments is provided
  if [ $# -ne 1 ]; then
    echo "Usage: mkdirg directory_name"
    return 1
  fi

  # Store the directory name provided as an argument
  local directory_name="$1"

  # Check if the directory already exists
  if [ -d "$directory_name" ]; then
    echo "Directory already exists: $directory_name"
    return 1
  fi

  # Create the directory and navigate into it
  mkdir -p "$directory_name" && cd "$directory_name" || exit
}

# Check if Description is present in the script, add if not
grep -q "# Description:" "$0" || sed -i '2i# Description:' "$0"

# Check if Usage Example is present in the script, add if not
grep -q "# Usage Example:" "$0" || sed -i '/# Description/a# Usage Example:' "$0"

# Show the entire script with improvements
cat "$0"

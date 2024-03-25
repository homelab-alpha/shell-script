#!/bin/bash

# Script: mvg.sh
# Description: This script moves a file or directory to a specified destination and then enters the destination directory.
# Author: GJS (homelab-alpha)
# Date: 2024-03-13T07:38:29Z

# Function: mvg
# Example usage: source_file.txt destination_directory/

function mvg() {
  # Check the number of arguments
  if [ $# -ne 2 ]; then
    echo "Usage: mvg source destination"
    return 1
  fi

  local source="$1"
  local destination="$2"

  # Check if source exists
  if [ ! -e "$source" ]; then
    echo "Source does not exist: $source"
    return 1
  fi

  # Check if destination exists and is a directory
  if [ ! -d "$destination" ]; then
    echo "Destination is not a directory: $destination"
    return 1
  fi

  # Move and enter directory
  mv "$source" "$destination" && cd "$destination/$(basename "$source")" || exit
}

# Add Description to the script if it's not present
description=$(grep -c "# Description:" "$0")
if [ "$description" -eq 0 ]; then
  sed -i '2i# Description: This script moves a file or directory to a specified destination and then enters the destination directory.' "$0"
fi

# Add Usage Example to the script if it's not present
usage_example=$(grep -c "# Example usage:" "$0")
if [ "$usage_example" -eq 0 ]; then
  sed -i '4i# Example usage: ./mvg.sh source_file.txt destination_directory/' "$0"
fi

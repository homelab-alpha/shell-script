#!/bin/bash

# Script: up.sh
# Description: This is a template for bash scripts. It serves as a starting point for creating new scripts.
# Author: GJS (homelab-alpha)
# Date: 2024-03-13T07:38:20Z

# Function: up
# Example:
# This script defines a function 'up()' to navigate up a specified number of directory levels in the file system.
# To use it, execute the script in a terminal and provide the number of levels to move up.
# Example usage:
#   # Move up one directory level (equivalent to 'cd ..')
#   up
#
#   # Move up three directory levels
#   up 3

function up() {
  local levels=${1:-1} # Set the default level to 1 if not specified
  local target=""

  for ((i = 1; i <= levels; i++)); do
    target="../$target"
  done

  if [ -z "$target" ]; then
    target=".."
  fi

  cd "$target" || return 1 # Go to the target directory or return an error code if it fails
}

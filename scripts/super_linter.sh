#!/bin/bash

# Filename: super_linter.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-20T10:37:53+02:00
# Version: 1.1.2

# Description: This script facilitates local linting of code repositories using
# the Github Super Linter tool. It wraps the Super Linter Docker container,
# providing options for linting either a local Git repository or a specific folder.

# Usage: ./super_linter.sh

# Default debug mode
DEBUG=false

# Function to run Docker with the standard options
run_docker_super_linter() {
  docker run \
    --env DEFAULT_BRANCH=main \
    --env RUN_LOCAL=true \
    --name super-linter \
    --pull=always \
    --rm \
    --volume "$PWD":/tmp/lint \
    "$@" \
    ghcr.io/super-linter/super-linter:latest
}

# Function to run Docker with the extra option USE_FIND_ALGORITHM=true
run_docker_super_linter_file() {
  docker run \
    --env DEFAULT_BRANCH=main \
    --env RUN_LOCAL=true \
    --env USE_FIND_ALGORITHM=true \
    --name super-linter \
    --pull=always \
    --rm \
    --volume "$PWD":/tmp/lint/file \
    "$@" \
    ghcr.io/super-linter/super-linter:latest
}

# Process command line options
while [[ "$#" -gt 0 ]]; do
  case $1 in
  -d | --debug)
    DEBUG=true
    ;;
  *)
    echo "Unknown parameter: $1"
    exit 1
    ;;
  esac
  shift
done

# Check if debug mode is enabled
if [ "$DEBUG" = true ]; then
  echo "Debug mode is enabled."
fi

# Menu
echo "Choose an option:"
echo "1. Root directory"
echo "2. Local File or Folder"
read -rp "Enter the number of the desired option: " choice

# Execute the selected option
case $choice in
1)
  if [ "$DEBUG" = true ]; then
    run_docker_super_linter -e LOG_LEVEL=DEBUG
  else
    run_docker_super_linter
  fi
  ;;
2)
  if [ "$DEBUG" = true ]; then
    run_docker_super_linter_file -e LOG_LEVEL=DEBUG
  else
    run_docker_super_linter_file
  fi
  ;;
*)
  echo "Invalid choice. Enter 1 or 2."
  ;;
esac

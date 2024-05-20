#!/bin/bash

# Script Name: gpg_keygen_script.sh
# Author: GJS (homelab-aplha)
# Date: 2024-05-18T12:08:56+02:00
# Version: 1.0.1

# Description: This script generates a GPG key pair for secure communication.
# It checks for required software, generates the key pair, and logs the actions.
# The script also provides options for verbose output and specifying the GPG directory.

# Usage: ./gpg_keygen_script.sh [-v] [-d /path/to/gpg_directory]

# Options:
#   -v, --verbose    Enable verbose mode
#   -d, --directory  Specify the path to the GPG directory (default is \$HOME/.gnupg)

# Examples:
# Generate key pair:
# $ ./gpg_keygen_script.sh
# Verbose mode:
# $ ./gpg_keygen_script.sh -v
# Specify GPG directory:
# $ ./gpg_keygen_script.sh -d /path/to/gpg_directory

# Notes:
# - Requires GPG to be installed. If not installed, the script will exit with an error message.
# - Checks for existing GPG key pair and prevents generation if it already exists.
# - Logs all actions and errors to a specified log file.

# Functions:

# Function to print text in cyan color
print_cyan() {
  echo -e "\e[36m$1\e[0m"
}

# Function to print section headers
print_section_header() {
  echo ""
  echo ""
  echo -e "$(print_cyan "=== $1 ===")"
}

# Function for displaying verbose information
display_verbose_info() {
  if [ "$verbose" == "true" ]; then
    print_section_header "GPG Key:"
    gpg --list-keys --keyid-format LONG
  fi
}

# Function for logging actions and errors to a single log file
log_message() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  local message="$1"

  echo "${timestamp} - ${message}" | tee -a "$log_file" >&2
}

# Function for displaying usage instructions
display_usage() {
  echo "Usage: $0 [-v] [-d /path/to/gpg_directory]"
  echo "Options:"
  echo "  -v, --verbose    Enable verbose mode"
  echo "  -d, --directory  Specify the path to the GPG directory (default is \$HOME/.gnupg)"
  exit 1
}

# Function for checking required software and informing the user if not present
check_required_software() {
  if ! command -v "gpg" >/dev/null 2>&1; then
    log_message "Error: GPG is not installed. Please install GPG before running this script."
    exit 1
  else
    log_message "GPG is installed."
  fi
}

# Function for generating the GPG key pair
generate_key_pair() {
  log_message "Generating new GPG key pair..."
  print_section_header "Generating new GPG key pair"
  log_message "Executing command: gpg --full-generate-key"
  gpg --full-generate-key
}

# Function for checking the existence of the key file
check_key_file_existence() {
  if [ -f "$gpg_dir/pubring.kbx" ]; then
    log_message "The GPG key pair already exists."
    log_message "=== end of the log ==="
    echo "$(print_cyan "Error:") The GPG key pair already exists."
    exit 1
  fi
}

# Function for processing command line options
parse_command_line_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -v | --verbose)
      verbose=true
      shift
      ;;
    -d | --directory)
      shift
      gpg_dir="$1"
      shift
      ;;
    *)
      display_usage
      ;;
    esac
  done
}

# Trap signals (interrupts)
trap trap_handler SIGINT SIGTERM

# Main Program:

# Default values
gpg_dir="$HOME/.gnupg"
log_file="$gpg_dir/gpg_keygen_script.log"

# Start logging
echo "" >>"$log_file" # Add an empty line after the marker for separation
log_message "=== beginning of the log ==="
log_message "Script execution started"

# Check if required software is installed
check_required_software

# Initialize options
verbose=false

# Parse command line options
parse_command_line_options "$@"

# Check if the GPG directory and log file exist, create them if they don't
if [ ! -d "$gpg_dir" ]; then
  mkdir -p "$gpg_dir" && log_message "Created directory: $gpg_dir"
fi

if [ ! -f "$log_file" ]; then
  touch "$log_file" && log_message "Created log file: $log_file"
fi

# Check if the GPG key pair already exists
check_key_file_existence

# Generate GPG key pair
generate_key_pair

# Display verbose information
display_verbose_info

# Logging completion
log_message "Script execution completed."
log_message "=== end of the log ==="

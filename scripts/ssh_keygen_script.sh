#!/bin/bash

# Script Name: ssh_keygen_script.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:30+02:00
# Version: 1.0.1

# Description: This script automates the generation and conversion of SSH key
# pairs for secure communication. It supports both ed25519 and RSA key types,
# allowing users to specify the desired key type, filename for the key pair, and
# SSH directory. The script logs all actions and errors to a designated log file
# for traceability.

# Usage: ./ssh_keygen_script.sh [-v] [-d /path/to/ssh_directory]
# Options:
#   -v, --verbose    Enable verbose mode to display detailed information during execution.
#   -d, --directory  Specify the path to the SSH directory. The default directory is $HOME/.ssh.

# Examples:
# 1. Generate and convert an SSH key pair:
#    ./ssh_keygen_script.sh

# 2. Generate and convert an SSH key pair with verbose output:
#    ./ssh_keygen_script.sh -v

# 3. Generate and convert an SSH key pair with a custom SSH directory:
#    ./ssh_keygen_script.sh -d /custom/path/to/ssh_directory

# Notes:
# - If the script encounters any errors during key generation or conversion,
#   it will exit with a non-zero status.
# - The script ensures that duplicate key filenames are not overwritten to
#   prevent accidental data loss.
# - Verbose mode provides additional information about the key pair generation
#   and conversion process, including the contents of the generated and
#   converted public keys.

# Default values
ssh_dir="$HOME/.ssh"                      # Default SSH directory
file_extension="ppk"                      # Default file extension for converted keys
log_file="$ssh_dir/ssh_keygen_script.log" # Log file path

# Function to print text in cyan color
print_cyan() {
  echo -e "\e[36m$1\e[0m" # Print text in cyan color
}

# Function to print section headers
print_section_header() {
  echo ""                              # Add a newline for separation
  echo ""                              # Add another newline for better readability
  echo -e "$(print_cyan "=== $1 ===")" # Print section header in cyan color
}

# Function for displaying verbose information
display_verbose_info() {
  local key_type="$1"
  local key_file="$2"
  local extension="$3"

  if [ "$verbose" == "true" ]; then # Check if verbose mode is enabled
    print_cyan "${key_type} public key:"
    cat "${key_file}.pub" # Print public key
    print_cyan "Converted ${key_type} public key:"
    cat "${key_file}.${extension}" # Print converted public key
  fi
}

# Function for logging actions and errors to a single log file
log_message() {
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S") # Get current timestamp

  echo "${timestamp} - ${1}" >>"$log_file" 2>&1 # Append message to log file
}

# Start logging
echo "" >>"$log_file"                      # Add an empty line after the marker for separation
log_message "=== beginning of the log ===" # Log script execution start
log_message "Script execution started"     # Log script execution start

# Function for displaying usage instructions
display_usage() {
  echo "Usage: $0 [-v] [-d /path/to/ssh_directory]" # Print usage instructions
  echo "Options:"
  echo "  -v, --verbose    Enable verbose mode"                                            # Enable verbose mode option
  echo "  -d, --directory  Specify the path to the SSH directory (default is \$HOME/.ssh)" # Specify SSH directory option
  exit 1                                                                                   # Exit script with error status
}

# Function for checking required software and informing the user if not present
check_required_software() {
  local software_list=("ssh-keygen" "putty") # List of required software
  local missing_software=()                  # Initialize list for missing software

  for software in "${software_list[@]}"; do
    if ! command -v "$software" >/dev/null 2>&1; then # Check if software is installed
      missing_software+=("$software")                 # Add missing software to list
    fi
  done

  if [ ${#missing_software[@]} -eq 0 ]; then          # Check if all required software is installed
    log_message "All required software is installed." # Log message
  else
    log_message "Error: The following required software is not installed: ${missing_software[*]}" # Log missing software
    log_message "Please install the missing software manually."                                   # Log instruction to install missing software
    exit 1                                                                                        # Exit script with error status
  fi
}

# Function for trapping signals (interrupts)
trap_handler() {
  echo ""                                                    # Print an empty line for better formatting
  log_message "Script execution interrupted. Cleaning up..." # Log message
  echo "=== end of the log ===" >>"$log_file"                # Add marker for the end of the log
  exit 1                                                     # Exit script with error status
}

# Function for generating key pair
generate_key_pair() {
  local key_type="$1"  # Key type (e.g., "ed25519" or "rsa")
  local file_name="$2" # Filename for the key pair

  log_message "Generating new ${key_type} SSH key pair for server: ${server}, filename: ${file_name}"                       # Log message
  print_section_header "Generating new ${key_type} SSH key pair"                                                            # Print section header
  if ssh-keygen -a 100 -C "${server}" -f "${ssh_dir}/id_${key_type}_${file_name}" -t "${key_type}" >>"$log_file" 2>&1; then # Generate key pair
    log_message "Successfully generated ${key_type} SSH key pair for filename: ${file_name}"                                # Log message
  else
    log_message "Failed to generate ${key_type} SSH key pair for filename: ${file_name}" # Log message
    log_message "=== end of the log ==="                                                 # Add marker for the end of the log
    exit 1                                                                               # Exit script with error status
  fi
}

# Function for converting key pair
convert_key_pair() {
  local key_type="$1"  # Key type (e.g., "ed25519" or "rsa")
  local file_name="$2" # Filename for the key pair

  log_message "Convert ${key_type} SSH key pair to ${file_name}.${file_extension}"                                                            # Log message
  print_section_header "Convert ${key_type} SSH key pair to ${file_name}.${file_extension}"                                                   # Print section header
  if puttygen "${ssh_dir}/id_${key_type}_${file_name}" -o "${ssh_dir}/id_${key_type}_${file_name}.${file_extension}" >>"$log_file" 2>&1; then # Convert key pair
    log_message "Successfully converted ${key_type} SSH key pair for filename: ${file_name}"                                                  # Log message
  else
    log_message "Failed to convert ${key_type} SSH key pair for filename: ${file_name}" # Log message
    log_message "=== end of the log ==="                                                # Add marker for the end of the log
    exit 1                                                                              # Exit script with error status
  fi
}

# Function for checking key file existence
check_key_file_existence() {
  local key_type="$1"  # Key type (e.g., "ed25519" or "rsa")
  local file_name="$2" # Filename for the key pair

  if [ -f "${ssh_dir}/id_${key_type}_${file_name}" ]; then                                               # Check if key file exists
    log_message "The ${key_type} SSH key pair already exists for filename: ${file_name}"                 # Log message
    log_message "=== end of the log ==="                                                                 # Add marker for the end of the log
    echo "$(print_cyan "Error:") The ${key_type} SSH key pair already exists for filename: ${file_name}" # Print error message
    exit 1                                                                                               # Exit script with error status
  fi
}

# Function for choosing key type
choose_key_type() {
  echo ""                                              # Print an empty line for better formatting
  print_cyan "Choose the SSH key type:"                # Print prompt in cyan color
  PS3="Enter your choice (1 for ed25519, 2 for RSA): " # Set prompt for select menu
  options=("ed25519" "RSA")                            # Options for key type selection
  select KEY_TYPE in "${options[@]}"; do               # Display select menu
    case $KEY_TYPE in
    "ed25519")
      check_key_file_existence "ed25519" "${file_name}"                                       # Check if key file already exists
      generate_key_pair "ed25519" "${file_name}"                                              # Generate key pair
      convert_key_pair "ed25519" "${file_name}"                                               # Convert key pair
      display_verbose_info "ed25519" "${ssh_dir}/id_ed25519_${file_name}" "${file_extension}" # Display verbose info
      log_message "Ed25519 SSH key pair generated and converted for filename: ${file_name}"   # Log message
      break                                                                                   # Exit loop
      ;;
    "RSA")
      check_key_file_existence "rsa" "${file_name}"                                     # Check if key file already exists
      generate_key_pair "rsa" "${file_name}"                                            # Generate key pair
      convert_key_pair "rsa" "${file_name}"                                             # Convert key pair
      display_verbose_info "RSA" "${ssh_dir}/id_rsa_${file_name}" "${file_extension}"   # Display verbose info
      log_message "RSA SSH key pair generated and converted for filename: ${file_name}" # Log message
      break                                                                             # Exit loop
      ;;
    *)
      echo "Invalid option. Choose 1 for ed25519 or 2 for RSA." # Print error message
      ;;
    esac
  done
}

# Check installed software and install if necessary
check_required_software

# Initialize options
verbose=false

# Parse command line options
while [[ $# -gt 0 ]]; do
  case "$1" in
  -v | --verbose)
    verbose=true
    shift
    ;;
  -d | --directory)
    shift
    ssh_dir="$1"
    shift
    ;;
  *)
    display_usage
    ;;
  esac
done

# Trap interrupts and clean up
trap trap_handler SIGINT SIGTERM

# Prompt for SSH key pair information
read -r -p "$(print_cyan "Enter the server name: ")" server
read -r -p "$(print_cyan "Enter the filename for the new SSH key pair: ")" file_name

# Check if the specified key file already exists
check_key_file_existence "ed25519" "${file_name}"
check_key_file_existence "rsa" "${file_name}"

# Choose key type and generate/convert key pair
choose_key_type

# Logging completion
log_message "Script execution completed for filename: ${file_name}"
log_message "=== end of the log ==="

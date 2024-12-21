#!/bin/bash

# Filename: uptime_kuma_pr_test_v2.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-21T08:02:34+01:00
# Version: 1.1.0

# Description:
# This script facilitates the testing of pull requests for Uptime-Kuma
# version 2.x.x within a Docker container environment. It prompts the user
# for a GitHub repository link that points to the pull request to be tested.
# The script launches a Docker container with the specified Uptime-Kuma image,
# allowing developers to verify changes and ensure compatibility before merging.
# The testing process operates on designated ports for both the application and API.

# Aliases:
# To create convenient aliases for this script, add the following lines
# to your shell configuration file (e.g., .bashrc or .bash_aliases):
# alias uptime-kuma-pr-test="$HOME/uptime_kuma_pr_test_v2.sh"
# alias uptime-kuma-pr-test="$HOME/.bash_aliases/uptime_kuma_pr_test_v2.sh"

# Usage:
# Execute this script in the terminal with the command:
# ./uptime_kuma_pr_test_v2

# Define the default ports for the Uptime-Kuma application and API.
port_app=3000 # Port for the main application
port_api=3001 # Port for the API

# Retrieve current user information.
# - username: the name of the current user.
# - puid: the user ID (PUID) of the current user.
# - pgid: the group ID (PGID) of the current user.
username=$(whoami)
puid=$(id -u)
pgid=$(id -g)

# Function to display the help message.
display_help() {
  clear
  echo "======================================================================"
  echo "         Welcome to the Uptime-Kuma Pull Request Testing Tool         "
  echo "======================================================================"
  echo
  echo "Usage:"
  echo "  1. Select an option from the main menu."
  echo "  2. Follow the on-screen prompts to proceed."
  echo
  echo "Note:"
  echo "  Option 2 has limited write permissions implemented."
  echo "  This limitation causes the container to exit unexpectedly when using"
  echo "  images louislam/uptime-kuma:pr-test2."
  echo
  echo "Options:"
  echo
  echo "  1. Uptime-Kuma Pull Request version: 2.x.x"
  echo "     Run a container with the louislam/uptime-kuma:pr-test2 image."
  echo
  echo "  2. Uptime-Kuma Pull Request version: 2.x.x with Persistent Storage"
  echo "     Run a container with the louislam/uptime-kuma:pr-test2 image."
  echo
  echo "Additional Options:"
  echo "  h or --help      : Display this help message."
  echo "  i or --info      : Show current user's information (PUID and PGID),"
  echo "                     as well as Docker and Docker Compose versions."
  echo "  q or --quit      : Quit the script."
  echo
  echo "For more information, visit:"
  echo "  https://github.com/louislam/uptime-kuma/wiki/Test-Pull-Requests"
  echo
  echo "======================================================================"
}

# Retrieve system, user, and Docker information.
display_system_info() {
  clear
  echo "======================================================================"
  echo "         Welcome to the Uptime-Kuma Pull Request Testing Tool         "
  echo "======================================================================"
  echo

  # Extract OS name from /etc/os-release.
  if [ -f /etc/os-release ]; then
    os_name=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
  else
    # Default if the OS name cannot be determined
    os_name="Unknown OS"
  fi

  # Retrieve kernel version.
  kernel_info=$(uname -r)

  # Determine filesystem type of the root directory.
  filesystem=$(findmnt -n -o FSTYPE /)

  # Check for Docker and Docker Compose, displaying versions if installed.
  if command -v docker &>/dev/null; then
    # Get Docker version
    docker_version=$(docker --version)
  else
    # Message if Docker is not found
    docker_version="Docker is not installed."
  fi

  if command -v docker compose &>/dev/null; then
    # Get Docker Compose version
    docker_compose_version=$(docker compose version)
  else
    # Message if Docker Compose is not found
    docker_compose_version="Docker Compose is not installed."
  fi

  # Display collected information.
  echo -e "Operating System Information:"
  echo -e "OS: $os_name"
  echo -e "Kernel Version: $kernel_info"
  echo -e "Filesystem: $filesystem"
  echo
  echo -e "User Information:"
  echo -e "Username: $username"
  echo -e "PUID: $puid"
  echo -e "PGID: $pgid"
  echo
  echo -e "Docker Information:"
  echo -e "$docker_version"
  echo -e "$docker_compose_version"
  echo
  echo "======================================================================"
}

# Validate GitHub repository link format (expected: 'owner:repo')
validate_repo_name() {
  if [[ ! "$1" =~ ^[a-zA-Z0-9._-]+:[a-zA-Z0-9._-]+$ ]]; then
    echo "Error: Invalid GitHub repository format. Use 'owner:repo' (e.g., 'Ionys320:master')."
    # Exit if the command fails
    exit 1
  fi
}

# Run Uptime-Kuma container for version 2 without persistent storage.
version_2() {
  echo "Running Uptime-Kuma version 2.x.x..."

  # Check if the container is already running.
  if [ "$(docker ps -q -f name=uptime-kuma-pr-test-v2)" ]; then
    echo "Error: The container 'uptime-kuma-pr-test-v2' is already running."
    # Exit if the container is already running
    exit 1
  fi

  # Execute the Docker run command with necessary environment variables and options.
  docker run \
    --env RUN_LOCAL=true \
    --env UPTIME_KUMA_GH_REPO="$pr_repo_name" \
    --env PUID="$puid" \
    --env PGID="$pgid" \
    --name uptime-kuma-pr-test-v2 \
    --pull=always \
    --rm \
    --publish "$port_app:3000/tcp" \
    --publish "$port_api:3001/tcp" \
    --security-opt no-new-privileges:true \
    --interactive \
    --tty \
    louislam/uptime-kuma:pr-test2 || {
    echo
    echo "Exiting container. Goodbye! Use CTRL+C to terminate."
    # Exit if the command fails or was terminated using CTRL+C
    exit 1
  }
}

# Run Uptime-Kuma container for version 2 with persistent storage.
version_2_persistent_storage() {
  echo "Running Uptime-Kuma version 2.x.x with persistent storage..."

  # Check if the container is already running.
  if [ "$(docker ps -q -f name=uptime-kuma-pr-test-v2)" ]; then
    echo "Error: The container 'uptime-kuma-pr-test-v2' is already running."
    # Exit if the container is already running
    exit 1
  fi

  # Execute the Docker run command with necessary environment variables, options, and volume mapping for persistence.
  docker run \
    --env RUN_LOCAL=true \
    --env UPTIME_KUMA_GH_REPO="$pr_repo_name" \
    --env PUID="$puid" \
    --env PGID="$pgid" \
    --name uptime-kuma-pr-test-v2 \
    --pull=always \
    --rm \
    --publish "$port_app:3000/tcp" \
    --publish "$port_api:3001/tcp" \
    --security-opt no-new-privileges:true \
    --interactive \
    --tty \
    --volume uptime-kuma-pr-test-v2:/app/data \
    louislam/uptime-kuma:pr-test2 || {
    echo
    echo "Exiting container. Goodbye! Use CTRL+C to terminate."
    # Exit if the command fails or was terminated using CTRL+C
    exit 1
  }
}

# Remove unused Docker images to free up disk space.
cleanup_dangling_images() {
  echo "Removing unused Docker images to free up storage..."
  # Prune dangling images to recover disk space.
  docker image prune --filter "dangling=true" -f || {
    echo "Error: Failed to prune Docker images. Please check your Docker setup."
    # Exit if the command fails
    exit 1
  }
}

# Main execution starts here.

# Main menu loop for user interaction.
while true; do
  clear
  echo "======================================================================"
  echo "         Welcome to the Uptime-Kuma Pull Request Testing Tool         "
  echo "======================================================================"
  echo
  echo "Please choose an option:"
  echo
  echo "   1. Uptime-Kuma Pull Request version: 2.x.x"
  echo "   2. Uptime-Kuma Pull Request version: 2.x.x with Persistent Storage"
  echo
  echo "   q: quit   h: help   i: info"
  echo "======================================================================"
  echo
  read -r -p "Please select an option (1, 2, h, i, or q to exit): " choice

  case $choice in
  1)
    selected_option="version_2"
    break
    ;;
  2)
    selected_option="version_2_persistent_storage"
    break
    ;;
  h | --help)
    # Show help message
    display_help
    echo
    # Wait for user input
    read -n 1 -s -r -p "Press any key to continue..."
    continue
    ;;
  i | --info)
    # Show system info
    display_system_info
    echo
    # Wait for user input
    read -n 1 -s -r -p "Press any key to continue..."
    continue
    ;;
  q | --quit)
    echo
    echo "Exiting the script Goodbye!."
    echo
    echo "Thank you for using the Uptime-Kuma Pull Request Testing Tool."
    # Exiting the script
    exit 0
    ;;
  *)
    echo "Error: Invalid option. Please try again." # Error message for invalid option
    ;;
  esac
done

# Prompt for the GitHub repository link and validate the format
read -r -p "Please enter the GitHub repository link here (e.g., Ionys320:master): " pr_repo_name
validate_repo_name "$pr_repo_name"

# Execute the selected Docker run command
$selected_option

# Clean up dangling Docker images
cleanup_dangling_images

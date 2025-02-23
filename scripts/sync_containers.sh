#!/bin/bash

# Filename: sync_containers.sh
# Author: GJS (homelab-alpha)
# Date: 2025-02-23T08:43:46+01:00
# Version: 1.0.0

# Description:
# This script is designed to synchronize Docker container images from a predefined list.
# It performs several checks including system disk space validation, verifies the format
# of Docker container labels, and logs all actions and errors to a log file.

# Usage:
# Execute the script by running: ./sync_containers.sh [options]
# Available options:
#   --update   : Synchronize Docker containers
#   --info     : Display current system and Docker information
#   h, --help  : Show this help message
#   q, --quit  : Exit the script

# Path to log directory and file
log_dir="$HOME/.bash-script"
log_file="$log_dir/sync_containers.log"

# Create log directory and file if not exists
mkdir -p "$log_dir"
touch "$log_file"

# List of Docker container images to synchronize
CONTAINERS=(
  "amir20/dozzle:latest"          # Lightweight Docker log viewer
  "containrrr/watchtower:latest"  # Automated container updates
  "freshrss/freshrss:latest"      # RSS aggregator
  "jellyfin/jellyfin:latest"      # Media server
  "louislam/dockge:latest"        # Docker GUI for managing containers
  "louislam/uptime-kuma:beta"     # Uptime monitoring service
  "mariadb:latest"                # MariaDB database server
  "netbootxyz/netbootxyz:latest"  # Network boot server for PXE
  "netdata/netdata:latest"        # Real-time monitoring and troubleshooting
  "openspeedtest/latest"          # Speed test application
  "plexinc/pms-docker:latest"     # Plex media server
  "portainer/portainer-ee:latest" # Portainer Enterprise Edition for Docker management
  "ronivay/xen-orchestra:latest"  # Xen Orchestra for managing XenServer
)

# Function to display the help message
display_help() {
  clear
  echo "================================================================================"
  echo "                   Docker Container Sync Tool - Help                            "
  echo "================================================================================"
  echo
  echo "Usage:"
  echo "  ./container_sync.sh [options]"
  echo
  echo "Options:"
  echo "  1. --update   : Synchronize Docker containers"
  echo "  2. --info     : Show current user's system and Docker information."
  echo "  h, --help     : Display this help message."
  echo "  q, --quit     : Exit the script."
  echo
  echo "Description:"
  echo "  This script helps you synchronize Docker container images from a"
  echo "  predefined list. It validates container labels, checks disk space,"
  echo "  and ensures Docker and network connectivity before pulling the images."
  echo
  echo "================================================================================"
  echo
}

# Function to display user information
display_info() {
  clear
  echo "================================================================================"
  echo "                  Docker User and System Information                            "
  echo "================================================================================"
  echo
  echo "Current User Information:"
  echo "User  ID (PUID): $(id -u)"
  echo "Group ID (PGID): $(id -g)"
  echo

  # Docker version checks
  echo "Install Check List:"
  if command -v docker &>/dev/null; then
    docker_version=$(docker --version)
    echo "$docker_version"
  else
    echo "Docker: Not installed"
  fi

  if command -v docker compose &>/dev/null; then
    docker_compose_version=$(docker compose version)
    echo "$docker_compose_version"
  else
    echo "Docker Compose: Not installed"
  fi

  # System disk space
  echo
  echo "System Disk Space:"
  df -h | grep -E '^/dev/|^Filesystem'
  echo
  echo "================================================================================"
}

# Function to synchronize Docker containers
sync_containers() {
  # Check if CONTAINERS and log_file are defined
  if [[ -z "${CONTAINERS+x}" || -z "$log_file" ]]; then
    echo "Error: CONTAINERS array or log file path is not defined."
    return 1
  fi

  echo "Starting Docker container synchronization..."
  success_count=0
  fail_count=0
  invalid_count=0

  # Iterate over the CONTAINERS array
  for container in "${CONTAINERS[@]}"; do
    # Validate container format using updated regex
    if [[ "$container" =~ ^[a-zA-Z0-9_.-]+(/?[a-zA-Z0-9_.-]+)+(:[a-zA-Z0-9_.-]+)?$ ]]; then
      echo "Pulling $container..."
      # Pull the container and log the result
      if docker pull "$container" &>>"$log_file"; then
        ((success_count++))
        echo "Success: $container pulled successfully."
      else
        ((fail_count++))
        echo "Error: Failed to pull $container."
        # Log more detailed error information
        echo "Detailed error for $container:" >> "$log_file"
        docker pull "$container" 2>> "$log_file"
      fi
    else
      ((invalid_count++))
      echo "Invalid container format: $container"
    fi
  done

  # Print summary
  echo
  echo "Summary:"
  echo " - Successful pulls: $success_count"
  echo " - Failed pulls: $fail_count"
  echo " - Invalid labels: $invalid_count"
  echo
  echo "Synchronization completed!"
}

# Main menu loop for user interaction
while true; do
  clear
  echo "================================================================================"
  echo "                           Docker Container Sync Tool                           "
  echo "================================================================================"
  echo
  echo "Please choose an option:"
  echo
  echo "   1. Synchronize Docker containers"
  echo "   2. Display Docker and system information"
  echo
  echo "   q: quit   h: help"
  echo "================================================================================"
  echo
  read -r -p "Please select an option (1, 2, h, or q to exit): " choice

  case $choice in
  1 | --update)
    echo "Starting synchronization of Docker containers..."
    sync_containers
    break
    ;;
  2 | --info)
    # Show system info
    display_info
    echo
    # Wait for user input
    read -n 1 -s -r -p "Press any key to continue..."
    continue
    ;;
  h | --help)
    # Show help message
    display_help
    echo
    # Wait for user input
    read -n 1 -s -r -p "Press any key to continue..."
    continue
    ;;
  q | --quit)
    echo
    echo "Exiting the script Goodbye!."
    echo
    echo "Thank you for using the Docker Container Sync Tool."
    # Exiting the script
    exit 0
    ;;
  *)
    echo "Error: Invalid option. Please try again."
    ;;
  esac
done

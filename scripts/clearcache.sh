#!/bin/bash

# Script Name: clearcache.sh
# Author: GJS (homelab-aplha)
# Date: 2024-05-18T12:08:45+02:00
# Version: 1.0.1

# Description: This script drop clean caches, as well as reclaimable slab
# objects like dentries and inodes.

# Usage: sudo ./clearcache.sh

# Example:
# sudo crontabe -e
# Example of a cronjob definition:
# ┌─────────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌─────────── day of the month (1 - 31)
# │ │ │ ┌───────── month (1 - 12) OR jan,feb,mar,apr ...
# │ │ │ │ ┌─────── day of the week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# │ │ │ │ │ ┌───── username that runs the command
# │ │ │ │ │ │ ┌─── command to execute (e.g., '/bin/command')
# │ │ │ │ │ │ │ ┌─ full path to your script or executable
# │ │ │ │ │ │ │ │
# * * * * *   / /   Placeholder for cronjob configuration
#
# Example with specified range and interval:
# This cron job will run every 3 hours from 07:00 to 23:00
#
# 10 07-23/3 * * * /bin/bash /pad/to/.bash_script/clearcache_ping.sh

# Path to log directory and file
log_dir="$HOME/.bash_script"
log_file="$log_dir/clearcache_cron.log"

# Function to log messages to a file
log_message() {
  local log_timestamp
  log_timestamp=$(date +"%Y-%m-%d %T")
  echo "[$log_timestamp] $1" >>"$log_file"
}

# Start logging
echo "" >>"$log_file"
log_message "=== beginning of the log ==="
log_message "INFO: Script execution started."

# Check if the script is run as root or with sudo
if [ "$EUID" -ne 0 ]; then
  log_message "ERROR: This script must be run as root or with sudo."
  log_message "=== end of the log ==="
  exit 1
fi

# Create log directory if it does not exist
if [ ! -d "$log_dir" ]; then
  mkdir -p "$log_dir" || {
    log_message "ERROR: Unable to create log directory: $log_dir"
    log_message "=== end of the log ==="
    exit 1
  }
  log_message "INFO: Log directory created: $log_dir"
fi

# Check if log file exists, if not, create it
if [ ! -f "$log_file" ]; then
  touch "$log_file" || {
    log_message "ERROR: Unable to create log file: $log_file"
    log_message "=== end of the log ==="
    exit 1
  }
  log_message "INFO: Log file created: $log_file"
fi


# Synchronize the file system
sync

# Check if /proc/sys/vm/drop_caches exists before writing 1
if [ -e /proc/sys/vm/drop_caches ]; then
  echo 1 >/proc/sys/vm/drop_caches
  log_message "INFO: File system caches have been cleared."
else
  log_message "ERROR: File /proc/sys/vm/drop_caches does not exist. Cache clearing failed."
  log_message "=== end of the log ==="
  exit 1
fi

# Log success message
log_message "INFO: Script execution completed successfully."
log_message "=== end of the log ==="

# End of script

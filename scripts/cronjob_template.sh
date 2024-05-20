#!/bin/bash

# Script Name: cronjob_template.sh
# Author: GJS (homelab-aplha)
# Date: 2024-05-18T12:08:48+02:00
# Version: 1.0.1

# Description: This script is a cronjob template and sends a ping to a
# monitoring server for system health check.

# Usage: sudo ./cronjob_template.sh

# - Ensure that 'curl' is installed to send a ping to the monitoring server.
# - Execute the script with root privileges using 'sudo'.

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
# 10 07-23/3 * * * /bin/bash /pad/to/.bash_script/cronjob_template.sh

# Function to log messages to a file
log_message() {
  local log_timestamp
  log_timestamp=$(date +"%Y-%m-%d %T")
  echo "[$log_timestamp] $1" >>"$log_file"
}

# Function to log verbose messages
log_verbose() {
  if [ "$verbose" == "true" ]; then
    log_message "$1"
  fi
}

# Function to log debug messages
log_debug() {
  if [ "$debug" == "true" ]; then
    log_message "DEBUG: $1"
  fi
}

# Function to log warnings
log_warning() {
  log_message "WARNING: $1"
}

# Function to send ping to Uptime Kuma monitoring server
send_ping_to_monitor_server() {
  log_verbose "Sending ping to monitoring server..."
  local url_with_params="$monitoring_server_url"
  local response_no_cert
  local response_with_cert
  if command -v curl &>/dev/null; then
    response_no_cert=$(curl -sS "$url_with_params")

    if [[ "$response_no_cert" == *"\"ok\":true"* ]]; then
      log_verbose "Monitoring server ping sent successfully without Self-signed certificate."
    else
      log_verbose "Sending ping with Self-signed certificate as the first attempt failed..."
      response_with_cert=$(curl -sS --cacert "$cert_file" "$url_with_params")
      if [[ "$response_with_cert" == *"\"ok\":true"* ]]; then
        log_verbose "Monitoring server ping sent successfully with Self-signed certificate."
      else
        log_warning "Monitoring server did not respond as expected (with Self-signed certificate). Response: $response_with_cert"
      fi
    fi

    # Log the responses if they are not empty
    if [ -n "$response_no_cert" ]; then
      log_debug "Response from server (without Self-signed certificate): $response_no_cert"
    fi

    if [ -n "$response_with_cert" ]; then
      log_debug "Response from server (with Self-signed certificate): $response_with_cert"
    fi
  else
    log_message "ERROR: 'curl' command not found. Install 'curl' to send a ping to the monitoring server."
  fi
}

# Main Program:

# Parse command line options
verbose="false"
debug="false"
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -v | --verbose)
    verbose="true"
    shift
    ;;
  -d | --debug)
    debug="true"
    shift
    ;;
  *)
    shift
    ;;
  esac
done

# Path to log directory and file
log_dir="$HOME/.bash_script"
log_file="$log_dir/cronjob_template_cron.log"

# Uptime Kuma Monitoring server URL and parameters
monitoring_server_url="<insert_url>"

# Name of the Certificate Authority you want to use for this script
cert_name="<insert_cert.crt"

# DO NOT EDIT: Certificate Authority Path for curl, this will break the script
cert_file=""

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

# Determine Certificate Authority file path based on the operating system
if [ -f /usr/local/share/ca-certificates/$cert_name ]; then
  cert_file="/usr/local/share/ca-certificates/$cert_name"
elif [ -f /etc/pki/ca-trust/source/anchors/$cert_name ]; then
  cert_file="/etc/pki/ca-trust/source/anchors/$cert_name"
else
  log_message "ERROR: Certificate file not found for this operating system."
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

####
#### insert code
####

# Send ping to monitoring server
send_ping_to_monitor_server

# Log success message
log_message "INFO: Script execution completed successfully."
log_message "=== end of the log ==="

# End of script

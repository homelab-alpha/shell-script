#!/bin/bash

# Filename: dns_check.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-26T11:59:51+02:00
# Version: 1.0.1

# Description: This script checks network connectivity and DNS server
# availability. It does not perform any specific task but can be used to
# diagnose network issues.

# Usage example: $ ./dns_check.sh

# Function to check network connectivity and DNS server availability
function dns-checker() {
  green="\e[32m"                          # ANSI color code for green
  red="\e[31m"                            # ANSI color code for red
  end="\e[0m"                             # ANSI color code to reset text formatting
  stamp="$(date +'[%b %d, %Y - %H%M%S]')" # Timestamp for log messages

  # Function to log messages with timestamp
  function log_message() {
    local message="$1"
    echo -e "$stamp $message"
  }

  # Function to check ping to a host
  function check_ping() {
    local host="$1"
    if ping -c 1 "$host" >/dev/null; then
      return 0
    else
      return 1
    fi
  }

  # Log message indicating the start of DNS server checks
  log_message "Checking primary DNS server (Enter your own DNS server IP address here)"
  if check_ping "Enter your own DNS server IP address here"; then
    log_message "Primary DNS server is ${green}UP${end} and running."
  else
    log_message "Primary DNS server seems to be ${red}DOWN${end}"
    log_message "Checking secondary DNS server (Enter your own DNS server IP address here)"
    if check_ping "Enter your own DNS server IP address here"; then
      log_message "Secondary DNS server is ${green}UP${end} and running."
    else
      log_message "Secondary DNS server seems to be ${red}DOWN${end}"
    fi
  fi

  # Check internet connectivity by pinging google.com
  log_message "Checking internet connectivity (ping google.com)"
  if check_ping "google.com"; then
    log_message "Network is ${green}UP${end} and running."
  else
    log_message "The network seems to be ${red}DOWN${end}"
    log_message "Checking external DNS servers..."
    if check_ping "9.9.9.9"; then
      log_message "Ping to 9.9.9.9 works, we have a DNS failure."
    else
      log_message "Ping to 9.9.9.9 failed, now pinging 149.112.112.112"
      if check_ping "149.112.112.112"; then
        log_message "Ping to 149.112.112.112 also failed, the network has an issue!"
        ifconfig >>"DNS_failure_interface_${stamp}.txt"
      fi
    fi
  fi
}

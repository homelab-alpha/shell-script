#!/bin/bash

# Script Name: check_system_info.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:08:42+02:00
# Version: 1.0.1

# Description: This script checks system information It provides details about
# system uptime, hardware information, system temperature, systemctl status,
# RAM/SWAP usage, disk usage, disk usage inodes, and last reboot/shutdown events.

# Usage: ./check_system_info.sh

# Function to print section separators
print_separator() {
    echo "────────────────────────────────────────────────────────────────────────────────"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Print section separator
print_separator
echo "$(date) │ $(whoami)@$(hostname --all-ip-addresses) │ $(uptime --pretty)"
print_separator

# Check for required commands
missing_commands=()
if ! command_exists "sensors"; then
    missing_commands+=("sensors")
fi
if ! command_exists "hostnamectl"; then
    missing_commands+=("hostnamectl")
fi
if ! command_exists "df"; then
    missing_commands+=("df")
fi
if ! command_exists "last"; then
    missing_commands+=("last")
fi

# Inform user about missing commands
if [ ${#missing_commands[@]} -eq 0 ]; then
    echo "All required software is present."
else
    echo "The following software is missing:"
    for cmd in "${missing_commands[@]}"; do
        echo " - $cmd"
    done
    echo "You can install missing software manually using your package manager."
fi

# Print section separator for clarity
print_separator

# System Info
echo "System info:"
echo ""
if command_exists "cat"; then
    cat /proc/device-tree/model
else
    echo "ERROR: 'cat' command not found."
fi
echo ""
if command_exists "hostnamectl"; then
    hostnamectl
else
    echo "ERROR: 'hostnamectl' command not found."
fi
print_separator

# System temperature
echo "System temperature:"
echo ""
if command_exists "sensors"; then
    sensors
else
    echo "ERROR: 'sensors' command not found."
fi
print_separator

# Systemctl status
echo "Systemctl status:"
echo ""
if command_exists "systemctl"; then
    systemctl --failed
else
    echo "ERROR: 'systemctl' command not found."
fi
print_separator

# RAM/SWAP usage
echo "RAM/SWAP usage:"
echo ""
if command_exists "free"; then
    free --human
else
    echo "ERROR: 'free' command not found."
fi
print_separator

# Disk usage
echo "Disk usage:"
echo ""
if command_exists "df"; then
    df --human-readable --type=ext4 --output=source,size,used,avail,pcent,target
else
    echo "ERROR: 'df' command not found."
fi
print_separator

# Disk usage inodes
echo "Disk usage inodes:"
echo ""
if command_exists "df"; then
    df --human-readable --inodes
else
    echo "ERROR: 'df' command not found."
fi
print_separator

# Last reboot/shutdown
echo "Last reboot/shutdown:"
echo ""
if command_exists "last"; then
    last --system | grep shutdown | head --lines=3
else
    echo "ERROR: 'last' command not found."
fi
print_separator

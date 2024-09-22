#!/usr/bin/env bash

# Filename: user_accounts_info.sh
# Author: GJS (homelab-aplha)
# Date: 2024-05-18T12:09:38+02:00
# Version: 1.0

# Description: This script retrieves information about system user accounts and
# organizes them into system and normal user categories.

# Usage: ./user_accounts_info.sh

# Notes:
# - This script requires read access to /etc/login.defs and /etc/passwd.
# - It uses awk for data processing.
# - Output is sorted based on UID and GID.

# Functions:

# Function to print header
print_header() {
  echo "==========================================================================================================="
  printf "%-15s %-15s %-30s %-25s %-20s\n" "UID" "GID" "Shell" "Username" "Groups"
  echo "==========================================================================================================="
}

# Main Program:

# File paths
login_defs="/etc/login.defs"
passwd_file="/etc/passwd"

# Check if required files exist
if [ ! -f "$login_defs" ] || [ ! -f "$passwd_file" ]; then
  echo "ERROR: Required files not found."
  exit 1
fi

# Get UID and GID limits
min_uid=$(awk '/^UID_MIN/{print $2}' "$login_defs")
max_uid=$(awk '/^UID_MAX/{print $2}' "$login_defs")
min_gid=$(awk '/^GID_MIN/{print $2}' "$login_defs")
max_gid=$(awk '/^GID_MAX/{print $2}' "$login_defs")

# Check if awk is available
if ! command -v awk &>/dev/null; then
  echo "ERROR: awk command not found."
  exit 1
fi

# Print system user accounts
print_header "System User Accounts"
awk -F':' -v "min_uid=$min_uid" -v "max_uid=$max_uid" -v "min_gid=$min_gid" -v "max_gid=$max_gid" '
    function get_user_groups(username) {
        "id -Gn " username | getline groups
        close("id -Gn " username)
        return groups
    }
    !($3 >= min_uid && $3 <= max_uid && $4 >= min_gid && $4 <= max_gid) {
        printf "%-15s %-15s %-30s %-25s %-20s\n", "UID: "$3, "GID: "$4, "Shell: "$7, $1, get_user_groups($1)
    }' "$passwd_file" | sort -n -t ':' -k 2

echo "" # Add a blank line between sections

# Print normal user accounts
print_header "Normal User Accounts"
awk -F':' -v "min_uid=$min_uid" -v "max_uid=$max_uid" -v "min_gid=$min_gid" -v "max_gid=$max_gid" '
    function get_user_groups(username) {
        "id -Gn " username | getline groups
        close("id -Gn " username)
        return groups
    }
    $3 >= min_uid && $3 <= max_uid && $4 >= min_gid && $4 <= max_gid {
        printf "%-15s %-15s %-30s %-25s %-20s\n", "UID: "$3, "GID: "$4, "Shell: "$7, $1, get_user_groups($1)
    }' "$passwd_file" | sort -n -t ':' -k 2

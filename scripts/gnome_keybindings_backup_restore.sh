#!/bin/bash

# Script Name: gnome_keybindings_backup_restore.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:08:51+02:00
# Version: 1.1.1

# Description: This script allows you to easily create backups of GNOME
# keybindings and restore them when needed. It creates a backup directory in the
# specified location and saves keybinding configurations for various GNOME components.
# You can then choose to make a backup or restore keybindings based on your preference.

# Requirements:
# - This script requires the 'dconf' utility to be installed on your system.
#   You can install it using the package manager of your Linux distribution.

# Usage: ./gnome_keybindings_backup_restore.sh

# Run the script in a terminal. When prompted, choose whether to make a backup
# of GNOME keybindings (option 1) or restore from a previous backup (option 2).

# Options:
#   1. Make a backup of GNOME keybindings
#   2. Restore the backup of GNOME keybindings

# Examples:

# Example 1: Create a backup of GNOME keybindings
#   ./gnome_keybindings_backup_restore.sh
#   What do you want to do?
#   1. Make a backup of GNOME keybindings
#   2. Restore the backup of GNOME keybindings
#   Choose 1 or 2: 1
#   Backup of GNOME keybindings completed.

# Example 2: Restore GNOME keybindings from a backup
#   ./gnome_keybindings_backup_restore.sh
#   What do you want to do?
#   1. Make a backup of GNOME keybindings
#   2. Restore the backup of GNOME keybindings
#   Choose 1 or 2: 2
#   Restoration of GNOME keybindings completed.

# Notes:
# - Ensure you have appropriate permissions to access and modify GNOME
#   keybinding configurations.
# - It's recommended to run this script with administrative privileges
#   (e.g., using sudo) to avoid permission issues.

check_create_backup_dir() {
  backup_dir="$HOME/Backup/Gnome/Keybindings $(date +'[%b %d, %Y %H:%M:%S]')"
  if [ ! -d "$backup_dir" ]; then
    mkdir -p "$backup_dir"
    echo "Backup directory created: $backup_dir"
  fi
}

# Function to perform backup
perform_backup() {
  check_create_backup_dir

  backup_dir="$HOME/Backup/Gnome/Keybindings $(date +'[%b %d, %Y %H:%M:%S]')"

  dconf dump / >"$backup_dir/dconf.conf"
  dconf dump /org/gnome/desktop/wm/keybindings/ >"$backup_dir/desktop_wm_keybindings"
  dconf dump /org/gnome/mutter/keybindings/ >"$backup_dir/mutter_keybindings"
  dconf dump /org/gnome/mutter/wayland/keybindings/ >"$backup_dir/mutter_wayland_keybindings"
  dconf dump /org/gnome/settings-daemon/plugins/media-keys/ >"$backup_dir/settings-daemon_plugins_media_keys"
  dconf dump /org/gnome/shell/keybindings/ >"$backup_dir/shell_keybindings"

  echo "Backup completed successfully. Backup directory: $backup_dir"
}

perform_restore() {
  backup_recovery_dir="$HOME/Backup/Gnome"

  # Check for available backups
  backups=("$backup_recovery_dir"/*)
  if [ ${#backups[@]} -eq 0 ]; then
    echo "No backups found."
    exit 1
  fi

  # Let the user choose which backup to restore
  echo "Available backups:"
  for ((i = 0; i < ${#backups[@]}; i++)); do
    echo "$((i + 1)). $(basename "${backups[$i]}")"
  done
  read -r -p "Enter the number of the backup you want to restore: " choice

  # Validate user input
  re='^[0-9]+$'
  if ! [[ $choice =~ $re ]]; then
    echo "Invalid input: Please enter a number."
    exit 1
  fi

  index=$((choice - 1))
  if [ $index -lt 0 ] || [ $index -ge ${#backups[@]} ]; then
    echo "Invalid backup number."
    exit 1
  fi

  selected_backup="${backups[$index]}"

  # Reset keybindings configurations to default values
  dconf reset -f /org/gnome/desktop/wm/keybindings/
  dconf reset -f /org/gnome/mutter/keybindings/
  dconf reset -f /org/gnome/mutter/wayland/keybindings/
  dconf reset -f /org/gnome/settings-daemon/plugins/media-keys/
  dconf reset -f /org/gnome/shell/keybindings/

  # Insert a delay of 0.5 seconds
  sleep 0.5

  # Restore from selected backup
  dconf load /org/gnome/desktop/wm/keybindings/ <"$selected_backup/desktop_wm_keybindings"
  dconf load /org/gnome/mutter/keybindings/ <"$selected_backup/mutter_keybindings"
  dconf load /org/gnome/mutter/wayland/keybindings/ <"$selected_backup/mutter_wayland_keybindings"
  dconf load /org/gnome/settings-daemon/plugins/media-keys/ <"$selected_backup/settings-daemon_plugins_media_keys"
  dconf load /org/gnome/shell/keybindings/ <"$selected_backup/shell_keybindings"

  echo "Backup restored successfully from: $selected_backup"
}

# Main menu
echo "Welcome to the GNOME Keybindings Backup and Restore Script."
echo "Please choose an option:"
echo "1. Perform Backup"
echo "2. Perform Restore"
read -r -p "Enter your choice (1 or 2): " choice

case $choice in
1) perform_backup ;;
2) perform_restore ;;
*) echo "Invalid choice. Please enter either 1 or 2." ;;
esac

# End of script

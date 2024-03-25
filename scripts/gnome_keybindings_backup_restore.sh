#!/bin/bash

# GNOME Keybindings Backup and Restore Script

# Script Name: gnome_keybindings_backup_restore.sh
# Author: GJS (homelab-alpha)
# Date: 2024-03-13T09:58:50Z
# Version: 1.0

# Description:
# This script allows you to easily create backups of GNOME keybindings and restore them when needed.
# It creates a backup directory in the specified location and saves keybinding configurations for various GNOME components.
# You can then choose to make a backup or restore keybindings based on your preference.
#
# Requirements:
# - This script requires the 'dconf' utility to be installed on your system.
#   You can install it using the package manager of your Linux distribution.
#
# Usage:
# Run the script in a terminal.
# When prompted, choose whether to make a backup of GNOME keybindings (option 1) or restore from a previous backup (option 2).
#
# Options:
#   1. Make a backup of GNOME keybindings
#   2. Restore the backup of GNOME keybindings
#
# Examples:
# Example 1: Create a backup of GNOME keybindings
#   ./gnome_keybindings_backup_restore.sh
#   What do you want to do?
#   1. Make a backup of GNOME keybindings
#   2. Restore the backup of GNOME keybindings
#   Choose 1 or 2: 1
#   Backup of GNOME keybindings completed.
#
# Example 2: Restore GNOME keybindings from a backup
#   ./gnome_keybindings_backup_restore.sh
#   What do you want to do?
#   1. Make a backup of GNOME keybindings
#   2. Restore the backup of GNOME keybindings
#   Choose 1 or 2: 2
#   Restoration of GNOME keybindings completed.
#
# Notes:
# - Ensure you have appropriate permissions to access and modify GNOME keybinding configurations.
# - It's recommended to run this script with administrative privileges (e.g., using sudo) to avoid permission issues.
#
# End of script

# Check if the "Backup" directory exists, if not, create it
backup_dir="$HOME/Backup/Gnome/Keybindings $(date +'%b %d, %Y - %H%M%S')"
if [ ! -d "$backup_dir" ]; then
  mkdir -p "$backup_dir" # Create the backup directory if it doesn't exist
fi

# Function to create a backup of keybindings
make_backup() {
  if dconf dump /org/gnome/desktop/wm/keybindings/ >"$backup_dir/desktop_keybindings"; then
    echo "Backup of GNOME desktop keybindings completed."
  else
    echo "An error occurred while creating the backup of GNOME desktop keybindings."
  fi

  if dconf dump /org/gnome/mutter/keybindings/ >"$backup_dir/mutter_keybindings"; then
    echo "Backup of GNOME mutter keybindings completed."
  else
    echo "An error occurred while creating the backup of GNOME mutter keybindings."
  fi

  if dconf dump /org/gnome/mutter/wayland/keybindings/ >"$backup_dir/mutter_wayland_keybindings"; then
    echo "Backup of GNOME mutter wayland keybindings completed."
  else
    echo "An error occurred while creating the backup of GNOME mutter wayland keybindings."
  fi

  if dconf dump /org/gnome/settings-daemon/plugins/media-keys/ >"$backup_dir/media-keys"; then
    echo "Backup of GNOME media keys completed."
  else
    echo "An error occurred while creating the backup of GNOME media keys."
  fi

  if dconf dump /org/gnome/shell/keybindings/ >"$backup_dir/shell_keybindings"; then
    echo "Backup of GNOME shell keybindings completed."
  else
    echo "An error occurred while creating the backup of GNOME shell keybindings."
  fi
}

# Function to restore keybindings from backup
restore_backup() {
  if dconf load /org/gnome/desktop/wm/keybindings/ <"$backup_dir/desktop_keybindings"; then
    echo "Restoration of GNOME desktop keybindings completed."
  else
    echo "An error occurred while restoring the backup of GNOME desktop keybindings."
  fi

  if dconf load /org/gnome/mutter/keybindings/ <"$backup_dir/mutter_keybindings"; then
    echo "Restoration of GNOME mutter keybindings completed."
  else
    echo "An error occurred while restoring the backup of GNOME mutter keybindings."
  fi

  if dconf load /org/gnome/mutter/wayland/keybindings/ <"$backup_dir/mutter_wayland_keybindings"; then
    echo "Restoration of GNOME mutter wayland keybindings completed."
  else
    echo "An error occurred while restoring the backup of GNOME mutter wayland keybindings."
  fi

  if dconf load /org/gnome/settings-daemon/plugins/media-keys/ <"$backup_dir/media-keys"; then
    echo "Restoration of GNOME media keys completed."
  else
    echo "An error occurred while restoring the backup of GNOME media keys."
  fi

  if dconf load /org/gnome/shell/keybindings/ <"$backup_dir/shell_keybindings"; then
    echo "Restoration of GNOME shell keybindings completed."
  else
    echo "An error occurred while restoring the backup of GNOME shell keybindings."
  fi
}

# Ask the user what they want to do
echo "What do you want to do?"
echo "1. Make a backup of GNOME keybindings"
echo "2. Restore the backup of GNOME keybindings"
read -rp "Choose 1 or 2: " choice

# Check the user's choice
if [ "$choice" == "1" ]; then
  make_backup
elif [ "$choice" == "2" ]; then
  restore_backup
else
  echo "Invalid choice. Please enter 1 or 2."
fi

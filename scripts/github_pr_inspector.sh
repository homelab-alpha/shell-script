#!/bin/bash

# Filename: github_pr_inspector.sh
# Author: GJS (homelab-alpha)
# Date: 2025-01-03T10:36:34+01:00
# Version: 1.0.0

# Description:
# This script provides an interactive interface for generating .patch and .diff links
# for GitHub pull requests. It allows users to inspect PR changes directly in their
# terminal by accessing these links. The script supports interactive menu options,
# hardcoded repositories, and custom input, ensuring a flexible user experience.

# Usage:
# ./github_pr_inspector.sh [username/repository] [pr_number]
# - If no parameters are passed, an interactive menu is displayed.
# - Optional flags:
#   -h, --help   : Show the help menu with detailed instructions.
#   -r, --reset  : Reset the current session and start fresh.
#   -q, --quit   : Exit the script gracefully.

# Examples:
# 1. Generate links for PR #123 in a specific repository:
#    ./github_pr_inspector.sh username/repository 123
# 2. Use the interactive menu:
#    ./github_pr_inspector.sh

# Aliases:
# To create convenient aliases for this script, add the following lines
# to your shell configuration file (e.g., .bashrc or .bash_aliases):
# alias github-pr-inspector="$HOME/github_pr_inspector.sh"
# alias github-pr-inspector="$HOME/.bash_aliases/github_pr_inspector.sh"

# Function to check if required commands are available
check_requirements() {
  for cmd in curl less; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Error: Required command '$cmd' is not installed. Please install it and try again."
      exit 1
    fi
  done
}

# Function to print messages in color
print_in_color() {
  local color="$1"
  local message="$2"
  case "$color" in
  green) echo -e "\033[32m$message\033[0m" ;;
  cyan) echo -e "\033[36m$message\033[0m" ;;
  yellow) echo -e "\033[33m$message\033[0m" ;;
  red) echo -e "\033[31m$message\033[0m" ;;
  *) echo "$message" ;;
  esac
}

# Variable to store the GitHub Custom username and repository label
homelab_alpha_repository="Github: homelab-alpha"
custom_username_repository="Custom: username/repository"

# Function to display the help menu
display_help() {
  clear
  echo "================================================================================"
  echo "             Welcome to the GitHub Pull Request Patch/Diff Tool                 "
  echo "================================================================================"
  echo
  echo "Note:"
  echo "  This script generates .patch and .diff links for GitHub Pull Requests. These"
  echo "  links allow you to view the changes made in the pull request directly in your"
  echo "  terminal."
  echo
  echo "Usage:"
  echo "  1. Select an option from the main menu."
  echo "  2. Follow the on-screen prompts to proceed."
  echo
  echo "Menu Options:"
  echo
  echo "   1. $homelab_alpha_repository"
  echo "   2. GitHub: louislam/uptime-kuma"
  echo "   3. $custom_username_repository."
  echo
  echo "Additional Options:"
  echo
  echo "  h or --help      : Display this help message."
  echo "  r or --reset     : Clear all inputs (repository, pull request number, etc.) and"
  echo "                     restart the process with a fresh slate."
  echo "  t or --toggle    : Toggle between .patch and .diff as the default file extension."
  echo
  echo "  q or --quit      : Exit the script."
  echo
  echo "================================================================================"
}

# Function to validate and gather repository input
gather_input() {
  if [ -z "$username_repository" ]; then
    read -r -p "Enter a GitHub Username and Repository (e.g., 'homelab-alpha/shell-script'): " username_repository
  fi

  # Validate the repository format
  if [[ ! "$username_repository" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+$ ]]; then
    echo
    print_in_color red "Invalid repository format. Please use 'username/repository' (e.g., 'homelab-alpha/shell-script')."
    sleep 2
    username_repository=""
    return 1
  fi

  return 0
}

# Function to fetch and display patch or diff files
fetch_file() {
  local link="$1"
  local file_type="$2"

  echo
  print_in_color cyan "Generated $file_type link: $link"
  sleep 2
  response=$(curl -s -o /dev/null -w "%{http_code}" "$link")

  if [[ "$response" != "200" ]]; then
    echo
    echo red "Failed to fetch the $file_type file. Verify the PR number and repository."
    sleep 2
    return 1
  fi

  curl -s "$link" | less
  return 0
}

# Main menu function for user interaction
main_menu() {
  toggle=".patch"

  while true; do
    clear
    echo "================================================================================"
    echo "             Welcome to the GitHub Pull Request Patch/Diff Tool                 "
    echo "================================================================================"
    echo
    echo "Please choose an option:"
    echo
    echo "   1. $homelab_alpha_repository"
    echo "   2. GitHub: louislam/uptime-kuma"
    echo "   3. $custom_username_repository"
    echo
    echo "h: help   r: reset   t: toggle (current: $toggle)   q: quit"
    echo "================================================================================"
    echo

    read -r -p "Please select an option (1, 2, 3, h, r, t, or q to exit): " choice

    # Reset pr_number before custom GitHub input to prompt for new number
    if [[ "$choice" == "1" || "$choice" == "2" || "$choice" == "3" ]]; then
      pr_number=""
    fi

    case $choice in
    1)
      # Ask for GitHub repository if not provided
      if [ -z "$homelab_alpha_repo" ]; then
        read -r -p "Enter the GitHub repository (e.g., 'shell-script'): " homelab_alpha_repo
      fi

      homelab_alpha_repository="Github: homelab-alpha/$homelab_alpha_repo"

      read -r -p "Enter the pull request number: " pr_number
      link="https://patch-diff.githubusercontent.com/raw/homelab-alpha/$homelab_alpha_repo/pull/$pr_number"
      link+="$toggle"
      fetch_file "$link" "$toggle"
      ;;
    2)
      # Hardcoded values for GitHub username and repo
      read -r -p "Enter the pull request number: " pr_number
      link="https://patch-diff.githubusercontent.com/raw/louislam/uptime-kuma/pull/$pr_number"
      link+="$toggle"
      fetch_file "$link" "$toggle"
      ;;
    3)
      # GitHub Custom Input
      gather_input || continue
      custom_username_repository="Github: $username_repository"

      # Ask for PR number if not provided
      if [ -z "$pr_number" ]; then
        read -r -p "Enter the pull request number: " pr_number
      fi

      link="https://patch-diff.githubusercontent.com/raw/$username_repository/pull/$pr_number"
      link+="$toggle"
      fetch_file "$link" "$toggle"
      ;;
    r | --reset)
      # Reset all input and label to default
      homelab_alpha_repository="GitHub: homelab-alpha"
      homelab_alpha_repo=""

      custom_username_repository="Custom: username/repository"
      username_repository=""

      echo
      print_in_color yellow "Reset all input and label to default"
      sleep 1.5
      ;;
    t | --toggle)
      # Toggle default extension between .patch and .diff
      if [[ "$toggle" == ".patch" ]]; then
        toggle=".diff"
      else
        toggle=".patch"
      fi

      echo
      print_in_color yellow "Default file extension set to '$toggle'."
      sleep .5
      ;;
    h | --help)
      display_help
      read -n 1 -s -r -p "Press any key to continue..."
      ;;
    q | --quit)
      echo
      print_in_color green "Exiting the script. Goodbye!"
      exit 0
      ;;
    *)
      echo
      print_in_color red "Invalid choice. Please try again."
      sleep 1.5
      ;;
    esac
  done
}

# Check for required commands
check_requirements

# Handle command-line arguments
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  display_help
  exit 0
fi

if [[ $# -ge 2 ]]; then
  username_repository="$1"
  pr_number="$2"

  # Skip gather_input as we already have the repo and PR number
  link="https://patch-diff.githubusercontent.com/raw/$username_repository/pull/$pr_number"
  fetch_file "$link.patch" ".patch"
  fetch_file "$link.diff" ".diff"
  exit 0
fi

# Start interactive menu
main_menu

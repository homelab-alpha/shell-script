#!/bin/bash

# Script Name: maintain_git_repo.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:14+02:00
# Version: 1.0.1

# Description: This script automates the maintenance process of a Git repository.
# It cleans up unnecessary files and resets the commit history to provide a fresh start,
# improving repository organization and reducing size. This can be particularly useful
# after importing from another version control system or to ensure a clean history
# for better project management and collaboration.

# Usage: ./maintain_git_repo.sh

# Example:
# Suppose you have a Git repository with accumulated unnecessary files or a
# messy commit history. You can use this script to clean up the repository and
# start fresh, ensuring a clean history and organized structure. Simply execute
# the script in the repository directory to initiate the maintenance process.
# After executing the script, ensure that you review the changes and verify
# that everything is as expected before pushing the changes to the remote
# repository. Additionally, make sure that all team members are aware of the
# maintenance activity to avoid conflicts or misunderstandings.

# Create a new branch named "cleaned-history" without commit history
git checkout --orphan cleaned-history

# Add all files to the staging area
git add -A

# Make an initial commit with all files
git commit -am "maintenance: New start, a clean history"

# Delete the old "main" branch
git branch -D main

# Rename the current branch to "main"
git branch -m main

# Push the new "main" branch to the remote repository, forcing if necessary
git push -f origin main

# Close the terminal with Ctrl+D
exit 0

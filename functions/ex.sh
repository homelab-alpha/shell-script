#!/bin/bash

# Script: ex.sh
# Description: This script provides a convenient way to extract various archive formats including tar, zip, gzip, bzip2, rar, etc. It simplifies the extraction process by automatically detecting the file format and applying the appropriate extraction method.
# Author: GJS (homelab-alpha)
# Date: 2024-03-13T07:38:35Z

# Function: ex
# Usage: ex <input_file_or_directory>

# Function to extract various archive formats
function ex() {
  # Check if the input file exists
  if [ -f "$1" ]; then
    # Determine the file type and perform extraction accordingly
    case "$1" in
    *.tar.bz2) tar -jxvf "$1" ;;                         # Extract tar.bz2 archives
    *.tar.gz) tar -zxvf "$1" ;;                          # Extract tar.gz archives
    *.bz2) bunzip2 "$1" ;;                               # Extract .bz2 files
    *.dmg) hdiutil mount "$1" ;;                         # Mount .dmg disk images
    *.gz) gunzip "$1" ;;                                 # Extract .gz files
    *.tar) tar -xvf "$1" ;;                              # Extract .tar archives
    *.tbz2) tar -jxvf "$1" ;;                            # Extract .tbz2 archives
    *.tgz) tar -zxvf "$1" ;;                             # Extract .tgz archives
    *.zip | *.ZIP) unzip "$1" ;;                         # Extract .zip archives
    *.pax) pax -r <"$1" ;;                               # Extract .pax archives without using 'cat'
    *.pax.Z) uncompress "$1" --stdout | pax -r ;;        # Extract compressed .pax archives
    *.rar) unrar x "$1" ;;                               # Extract .rar archives
    *.Z) uncompress "$1" ;;                              # Extract .Z archives
    *) echo "$1 cannot be extracted/mounted via ex()" ;; # Unsupported file format
    esac
  else
    echo "$1 is not a valid file" # Print error message for non-existent files
  fi
}

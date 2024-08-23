#!/bin/bash

# Filename: audio_converter.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:13:28+02:00
# Version: 1.0

# Description: This script converts audio files in various formats
# (m4a, mp3, wma) to MP3 format with a bitrate of 128k, 44.1kHz sampling rate,
# and 2-channel audio.

# Dependencies: avconv, ffmpeg

# Usage: ./audio_converter.sh

# Enable case-insensitive matching
shopt -s nocasematch

# Define the directory for converted files
working_directory="./mp3_converted"

# Check if the directory exists, if not, create it
if [ ! -d "$working_directory" ]; then
  echo "Convert directory does not exist: $working_directory"
  mkdir -p "$working_directory"
  echo "Convert directory created: $working_directory"
fi

# Loop through each file in the current directory
for i in *; do
  case $i in
  *.mp3)
    # Convert mp3 files using avconv
    avconv -analyzeduration 999999999 -map_metadata 0 -i "$i" -vn -acodec libmp3lame -ac 2 -ab 128k -ar 44100 "$working_directory/$(basename "$i" .mp3).mp3"
    echo "$i converted to MP3"
    ;;
  *.m4a)
    # Convert m4a files using ffmpeg
    ffmpeg -i "$i" -n -acodec libmp3lame -ab 128k "$working_directory/$(basename "$i" .m4a).mp3"
    echo "$i converted to MP3"
    ;;
  *.wma)
    # Convert wma files using avconv
    avconv -analyzeduration 999999999 -map_metadata 0 -i "$i" -vn -acodec libmp3lame -ac 2 -ab 128k -ar 44100 "$working_directory/$(basename "$i" .wma).mp3"
    echo "$i converted to MP3"
    ;;
  *)
    echo "Skipping unrecognized file: $i"
    ;;
  esac
done

# Disable case-insensitive matching
shopt -u nocasematch

exit 0

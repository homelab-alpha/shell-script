#!/bin/bash

# Script: encrypt_and_decrypt.sh
# Description: This script provides functions to encrypt and decrypt files or directories using AES-256 encryption algorithm with OpenSSL.
# Author: GJS (homelab-alpha)
# Date: 2024-03-13T07:38:38Z

# Function: file-encrypt
# Usage: file-encrypt <input_file_or_directory>
#        <input_file_or_directory> - The file or directory to be encrypted.

# Function to encrypt files or directories with AES-256 encryption algorithm using OpenSSL.
function file-encrypt() {
    if [ -z "$1" ]; then
        echo "Usage: file-encrypt <input_file_or_directory>"
        return 1
    fi

    local input="$1"
    local output="${input}.aes256"

    if [ -e "$output" ]; then
        echo "Error: Output file already exists. Please choose a different name."
        return 1
    fi

    openssl enc -aes-256-ctr -pbkdf2 -salt -in "$input" -out "$output"
    if openssl_exit_code=$? && [ $openssl_exit_code -eq 0 ]; then
        echo ""
        echo "${input} has been successfully encrypted as ${output}."
        chmod 644 "$output"
    else
        echo "Encryption failed."
    fi
}

# Function: file-decrypt
# Function to decrypt files or directories encrypted with AES-256 encryption algorithm using OpenSSL.
# Description: Decrypts files or directories encrypted with AES-256 encryption algorithm using OpenSSL.
# Usage: file-decrypt <input_file>
#        <input_file> - The file to be decrypted.

function file-decrypt() {
    if [ -z "$1" ]; then
        echo "Usage: file-decrypt <input_file>"
        return 1
    fi

    local input="$1"
    local output="${input%.aes256}"

    if [ -e "$output" ]; then
        echo "Error: Output file already exists. Please choose a different name."
        return 1
    fi

    openssl enc -aes-256-ctr -pbkdf2 -d -salt -in "$input" -out "$output"
    if openssl_exit_code=$? && [ $openssl_exit_code -eq 0 ]; then
        echo ""
        echo "${input} has been successfully decrypted as ${output}."
        chmod 644 "$output"
    else
        echo "Decryption failed."
    fi
}

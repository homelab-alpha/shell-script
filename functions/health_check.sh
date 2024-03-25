#!/bin/bash

# Script: health_check.sh
# Description: This script checks the availability of a given URL using both HTTP and HTTPS protocols.
# Author: GJS (homelab-alpha)
# Date: 2024-03-12T15:08:42Z

# Example usage:
# This script can be executed by providing a URL as an argument.
# It checks the availability of the URL using both HTTP and HTTPS protocols.
# To use it, simply execute it in a terminal and provide the URL as an argument:
# ./health_check.sh example.com

function health-check() {
  green="\e[32m"
  red="\e[31m"
  end="\e[0m"

  if [ -z "$1" ]; then
    echo "Please provide a URL to check."
    return 1
  fi

  url="$1"

  protocols=("https" "http")

  for protocol in "${protocols[@]}"; do
    if curl --head --silent --show-error --fail --location "$protocol://$url"; then
      echo -e "$protocol://$url is ${green}UP${end} and running."
      return 0
    fi
  done

  echo -e "Both https://$url and http://$url are ${red}DOWN${end}"
  return 1
}

#!/bin/bash

# Filename: new_docker_compose_file.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:20+02:00
# Version: 1.0

# Description: This script creates a new Docker-Compose file and configuration
# files based on user input.

# Usage: ./new_docker_compose_file.sh

# Validate existence of required commands
for cmd in mkdir touch chown; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd command not found. Please install it and try again."
    exit 1
  fi
done

# Function to display informative messages
display_message() {
  echo -e "\n$1\n"
}

display_message "What is the name of the new Docker container:"
read -r container_name

# Validate container name
if [[ ! "$container_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  display_message "Invalid container name. Use only letters, numbers, underscore (_), and hyphen (-)."
  exit 1
fi

# Specify base directory for Docker containers (configurable)
base_dir="$HOME/Docker"
dir_path="$base_dir/$container_name"

# Check if directory already exists
if [ -d "$dir_path" ]; then
  display_message "The directory already exists. Choose a different name for the container."
  exit 1
fi

# Create the required directories
if ! mkdir -p "$dir_path"; then
  display_message "Failed to create directory: $dir_path"
  exit 1
fi

# Create Docker startup files
if ! touch "$dir_path/.env" "$dir_path/docker-compose.yml"; then
  display_message "Failed to create Docker startup files in $dir_path."
  exit 1
fi

# Add content to .env
cat <<EOL >"$dir_path/.env"
# API keys and secrets
API_KEY=
SECRET_KEY=

# App configuration
MYSQL_HOST_APP=${container_name}
MYSQL_PORT_APP=3306
MYSQL_NAME_APP=${container_name}
MYSQL_USER_APP=${container_name}
MYSQL_PASSWORD_APP=

# Database configuration
MYSQL_ROOT_PASSWORD_DB="
MYSQL_DATABASE_DB=${container_name}_db
MYSQL_USER_DB=${container_name}
MYSQL_PASSWORD_DB=
EOL

# Add content to docker-compose.yml
cat <<EOL >"$dir_path/docker-compose.yml"
version: "3.9"

networks:
  ${container_name}_net:
    attachable: false
    internal: false
    external: false
    name: ${container_name}
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/24
          ip_range: 172.20.0.0/24
          gateway: 172.20.0.1
    driver_opts:
      com.docker.network.bridge.default_bridge: "false"
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
      com.docker.network.bridge.host_binding_ipv4: "0.0.0.0"
      com.docker.network.bridge.name: "${container_name}"
      com.docker.network.driver.mtu: "1500"
    labels:
      com.${container_name}.network.description: "is an isolated bridge network."

services:
  ${container_name}_db:
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
    stop_grace_period: 1m
    container_name: ${container_name}_db
    image: change_me:latest
    init: false
    pull_policy: if_not_present
    volumes:
      - /docker/${container_name}/production/db:/change_me
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: Europe/Amsterdam
      MYSQL_RANDOM_ROOT_PASSWORD:
      MYSQL_ROOT_PASSWORD:
      MYSQL_DATABASE: "${container_name}_db"
      MYSQL_USER: "${container_name}"
      MYSQL_PASSWORD:
    command: ["--transaction-isolation=READ-COMMITTED", "--log-bin=binlog", "--binlog-format=ROW"]
    hostname: ${container_name}_db
    networks:
      ${container_name}_net:
        ipv4_address: 172.20.0.2
    security_opt:
      - no-new-privileges:true
    labels:
      com.${container_name}.db.description: "is a MySQL database."

  ${container_name}_app:
    restart: unless-stopped
    logging:
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
    stop_grace_period: 1m
    container_name: ${container_name}
    image: change_me:latest
    init: false
    pull_policy: if_not_present
    volumes:
      - /docker/${container_name}/production/app:/change_me
    env_file:
      - .env
    environment:
      PUID: "1000"
      PGID: "1000"
      TZ: Europe/Amsterdam
      MYSQL_HOST: "${container_name}_db"
      MYSQL_PORT: 3306
      MYSQL_NAME: "${container_name}_db"
      MYSQL_USER: "${container_name}"
      MYSQL_PASSWORD:
    command: ["change_me"]
    entrypoint: ["change_me"]
    domainname: ${container_name}.my-lan.nl
    hostname: ${container_name}
    extra_hosts:
      ${container_name}: "0.0.0.0"
    networks:
      ${container_name}_net:
        ipv4_address: 172.20.0.3
    dns:
      - 8.8.8.8
      - 8.8.4.4
    dns_search:
      - dc1.example.com
      - dc2.example.com
    dns_opt:
      - use-vc
      - no-tld-query
    ports:
      - ":/tcp"
      - ":/udp"
    devices:
      - "/dev/ttyUSB0:/dev/ttyUSB0"
      - "/dev/ttyACMO"
      - "/dev/sda:/dev/xvda:rwm"
    security_opt:
      - no-new-privileges:true
      - label:user:USER
      - label:role:ROLE
    cap_add:
      - CHANGE_ME
    cap_drop:
      - CHANGE_ME
    labels:
      com.docker.compose.project: "${container_name}"
      com.${container_name}.description: "change_me."

volumes:
  ${container_name}_db:
    external: true
  ${container_name}_app:
    external: true

secrets:
  mysql_root_passwrd:
    file: change_my.txt
    external: true
  mysql_db:
    file: change_my.txt
    external: true
  mysql_user:
    file: change_my.txt
    external: true
  mysql_password:
    file: change_my.txt
    external: true
  ${container_name}_admin_user:
    file: change_my.txt
    external: true
  ${container_name}_db_admin_password:
    file: change_my.txt
    external: true
EOL

display_message "Docker Compose File is created in $dir_path"

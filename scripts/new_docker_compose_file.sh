#!/bin/bash

# Filename: new_docker_compose_file.sh
# Author: GJS (homelab-alpha)
# Date: 2024-12-13T16:43:03+01:00
# Version: 1.2.1

# Description:
# This script automates the creation of a Docker-Compose environment based
# on user input. It sets up a new project by creating necessary directory
# structures, Docker Compose files, and configuration files for a database
# and application container setup. It requires the user to input a valid
# container name, and checks the existence of required tools such as mkdir,
# touch, and chown to ensure that the system is properly set up for container
# creation. The script generates the following files:
#   - docker-compose.yml: Defines Docker services and networks.
#   - testing_docker-compose.yml: A second configuration file for testing.
#   - .env: Environment file with database and application configuration.
#   - stack.env: Custom configuration file.
#   - my.cnf: MySQL configuration file.
# Additionally, it creates necessary directories like 'notes' for storing
# any project-specific files.

# Usage: ./new_docker_compose_file.sh
# This script will prompt you for the name of the container and then
# automatically create the necessary files.

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
read container_name

# Validate container name
if [[ ! "$container_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
  display_message "Invalid container name. Use only letters, numbers, underscore (_), and hyphen (-)."
  exit 1
fi

# Specify base directory for Docker containers (configurable)
base_dir="${HOME}/Docker"
dir_path="$base_dir/$container_name"

# Check if directory already exists
if [ -d "$dir_path" ]; then
  display_message "The directory already exists. Choose a different name for the container."
  exit 1
fi

# # Create the required directories
declare -a directories=(
  "notes"
)

for dir in "${directories[@]}"; do
  if ! mkdir -p "$dir_path/$dir"; then
    display_message "Failed to create directory: $dir_path/$dir"
    exit 1
  fi
done

# Create Docker startup files
if ! touch "$dir_path/docker-compose.yml" "$dir_path/testing_docker-compose.yml" "$dir_path/.env" "$dir_path/stack.env" "$dir_path/my.cnf"; then
  display_message "Failed to create Docker startup files in $dir_path."
  exit 1
fi

# Add content to docker-compose.yml
cat <<EOL >"$dir_path/docker-compose.yml"
---
networks:
  ${container_name}_net:
    attachable: false # If is set to true: then standalone containers should be able to attach to this network.
    internal: false # when set to true, allows you to create an externally isolated network.
    external: false # If set to true: specifies that this network’s lifecycle is maintained outside of that of the application.
    name: ${container_name}
    driver: bridge # host: Use the hosts networking stack and none: Turn off networking.
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/24   # Subnet in CIDR format that represents a network segment
          ip_range: 172.20.0.0/24 # Range of IPs from which to allocate container IPs
          gateway: 172.20.0.1     # IPv4 or IPv6 gateway for the master subnet
          # Auxiliary IPv4 or IPv6 addresses used by Network driver, as a mapping from hostname to IP
          # aux_addresses:
          #   host1: 172.20.0.2
          #   host2: 172.20.0.3
          #   host3: 172.20.0.4
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
    # deploy:
    #   resources:
    #     limits:
    #       cpus: "2.0"
    #       memory: 128M
    #     reservations:
    #       cpus: "0.25"
    #       memory: 64M
    #   restart_policy:
    #     condition: on-failure
    #     delay: 5s
    #     max_attempts: 3
    #     window: 120s
    restart: unless-stopped #"no", always, unless-stopped.
    logging:
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
      # driver: syslog
      # options:
      #   syslog-address: "tcp://192.168.0.0:123"
    stop_grace_period: 1m
      # specifies how long Compose must wait when attempting to stop a container.
    container_name: ${container_name}_db
    image: change_me:latest
    init: false
      # init runs an init process (PID 1) inside the container that forwards signals and reaps processes.
      # Set this option to true to enable this feature for the service.
    pull_policy: if_not_present # always, never, missing, if_not_present, build.
    volumes:
      - /docker/${container_name}/production/db:/var/lib/mysql
      - /docker/${container_name}/production/my.cnf:/etc/my.cnf
    env_file:
      # adds environment variables to the container based on the file content.
      - .env
      - stack.env
    environment:
      # Any boolean values; "true", "false", "yes", "no", should be enclosed in quotes.
      PUID: "1000" # UserID
      PGID: "1000" # GroupID
      TZ: Europe/Amsterdam
      MYSQL_RANDOM_ROOT_PASSWORD: \${MYSQL_RANDOM_ROOT_PASSWORD}
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD_DB}
      MYSQL_DATABASE: \${MYSQL_DATABASE_DB}
      MYSQL_USER: \${MYSQL_USER_DB}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD_DB}
    hostname: ${container_name}_db
    networks:
      ${container_name}_net:
        ipv4_address: 172.20.0.2
    # ports:
    #   - target: 3306       # container port
    #     host_ip: 127.0.0.1 # The Host IP mapping, unspecified means all network interfaces (0.0.0.0)
    #     published: 3306    # publicly exposed port
    #     protocol: tcp      # tcp or udp
    #     mode: ingress      # host: For publishing a host port on each node
    security_opt:
      - no-new-privileges:true
    labels:
      com.${container_name}.db.description: "is a MySQL database."
    healthcheck:
      disable: false
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 10s
      start_interval: 5s

  ${container_name}_app:
    # deploy:
    #   resources:
    #     limits:
    #       cpus: "2.0"
    #       memory: 128M
    #     reservations:
    #       cpus: "0.25"
    #       memory: 64M
    #   restart_policy:
    #     condition: on-failure
    #     delay: 5s
    #     max_attempts: 3
    #     window: 120s
    restart: unless-stopped #"no", always, unless-stopped.
    logging:
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
      # driver: syslog
      # options:
      #   syslog-address: "tcp://192.168.0.0:123"
    stop_grace_period: 1m
      # specifies how long Compose must wait when attempting to stop a container.
    container_name: ${container_name}
    image: change_me:latest
    init: false
      # init runs an init process (PID 1) inside the container that forwards signals and reaps processes.
      # Set this option to true to enable this feature for the service.
    pull_policy: if_not_present # always, never, missing, if_not_present, build.
    depends_on:
      ${container_name}_db:
        condition: service_healthy
        restart: true
      ${container_name}_redis:
        condition: service_healthy
    links:
      - ${container_name}_db
    volumes:
      # rw: Read and write access. ro: Read-only access. z: multiple containers. Z: private and unshared
      # - ${container_name}_app:/change_me
      # - /docker/${container_name}/production/.cert:/change_me
      - /docker/${container_name}/production/app:/change_me
      # - /docker/${container_name}/production/config/change_me:/change_me
      # - /docker/${container_name}/production/log:/change_me
      # - /docker/${container_name}/production/redis:/change_me
    env_file:
      # adds environment variables to the container based on the file content.
      - .env
      - stack.env
    environment:
      # Any boolean values; "true", "false", "yes", "no", should be enclosed in quotes.
      PUID: "1000" # UserID
      PGID: "1000" # GroupID
      TZ: Europe/Amsterdam
      MYSQL_HOST: \${MYSQL_HOST}
      MYSQL_PORT: \${MYSQL_PORT}
      MYSQL_NAME: \${MYSQL_DATABASE_DB}
      MYSQL_USER: \${MYSQL_USER_DB}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD_DB}
    command: ["change_me"]
    entrypoint: ["change_me"]
      # declares the default entrypoint for the service container.
      # This overrides the ENTRYPOINT instruction from the services Dockerfile.
    domainname: ${container_name}.local
    hostname: ${container_name}
    extra_hosts:
      ${container_name}: "0.0.0.0"
    networks:
      ${container_name}_net:
        ipv4_address: 172.20.0.3
    dns:
      # defines custom DNS servers to set on the container network interface configuration.
      # It can be a single value or a list.
      - 8.8.8.8
      - 8.8.4.4
    dns_search:
      # defines custom DNS search domains to set on container network interface configuration.
      # It can be a single value or a list.
      - dc1.example.com
      - dc2.example.com
    dns_opt:
      # list custom DNS options to be passed to the container’s DNS resolver (/etc/resolv.conf file on Linux).
      - use-vc
      - no-tld-query
    ports:
      - ":/tcp"
      - ":/udp"
    devices:
      # defines a list of device mappings for created containers-
      # in the form of HOST_PATH:CONTAINER_PATH[:CGROUP_PERMISSIONS].
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
    healthcheck:
      disable: true
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3
      start_period: 40s
      start_interval: 5s

volumes:
  ${container_name}_db:
    external: true
  ${container_name}_app:
    external: true
EOL

# Add content to testing_docker-compose.yml
cat <<EOL >"$dir_path/testing_docker-compose.yml"
---
networks:
  ${container_name}_testing_net:
    attachable: false # If is set to true: then standalone containers should be able to attach to this network.
    internal: false # when set to true, allows you to create an externally isolated network.
    external: false # If set to true: specifies that this network’s lifecycle is maintained outside of that of the application.
    name: ${container_name}_testing
    driver: bridge # host: Use the hosts networking stack and none: Turn off networking.
    ipam:
      driver: default
      config:
        - subnet: 172.20.0.0/24   # Subnet in CIDR format that represents a network segment
          ip_range: 172.20.0.0/24 # Range of IPs from which to allocate container IPs
          gateway: 172.20.0.1     # IPv4 or IPv6 gateway for the master subnet
          # Auxiliary IPv4 or IPv6 addresses used by Network driver, as a mapping from hostname to IP
          # aux_addresses:
          #   host1: 172.20.0.2
          #   host2: 172.20.0.3
          #   host3: 172.20.0.4
    driver_opts:
      com.docker.network.bridge.default_bridge: "false"
      com.docker.network.bridge.enable_icc: "true"
      com.docker.network.bridge.enable_ip_masquerade: "true"
      com.docker.network.bridge.host_binding_ipv4: "0.0.0.0"
      com.docker.network.bridge.name: "${container_name}_testing"
      com.docker.network.driver.mtu: "1500"
    labels:
      com.${container_name}.test.network.description: "is an isolated bridge network."

services:
  ${container_name}_testing_db:
    # deploy:
    #   resources:
    #     limits:
    #       cpus: "2.0"
    #       memory: 128M
    #     reservations:
    #       cpus: "0.25"
    #       memory: 64M
    #   restart_policy:
    #     condition: on-failure
    #     delay: 5s
    #     max_attempts: 3
    #     window: 120s
    restart: unless-stopped #"no", always, unless-stopped.
    logging:
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
      # driver: syslog
      # options:
      #   syslog-address: "tcp://192.168.0.0:123"
    stop_grace_period: 1m
      # specifies how long Compose must wait when attempting to stop a container.
    container_name: ${container_name}_testing_db
    image: change_me:latest
    init: false
      # init runs an init process (PID 1) inside the container that forwards signals and reaps processes.
      # Set this option to true to enable this feature for the service.
    pull_policy: if_not_present # always, never, missing, if_not_present, build.
    volumes:
      - /docker/${container_name}/testing/db:/var/lib/mysql
      - /docker/${container_name}/testing/my.cnf:/etc/my.cnf
    env_file:
      # adds environment variables to the container based on the file content.
      - .env
      - stack.env
    environment:
      # Any boolean values; "true", "false", "yes", "no", should be enclosed in quotes.
      PUID: "1000" # UserID
      PGID: "1000" # GroupID
      TZ: Europe/Amsterdam
      MYSQL_RANDOM_ROOT_PASSWORD: \${MYSQL_RANDOM_ROOT_PASSWORD}
      MYSQL_ROOT_PASSWORD: \${MYSQL_ROOT_PASSWORD_DB}
      MYSQL_DATABASE: \${MYSQL_DATABASE_DB}
      MYSQL_USER: \${MYSQL_USER_DB}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD_DB}
    hostname: ${container_name}_testing_db
    networks:
      ${container_name}_testing_net:
        ipv4_address: 172.20.0.2
    # ports:
    #   - target: 3306       # container port
    #     host_ip: 127.0.0.1 # The Host IP mapping, unspecified means all network interfaces (0.0.0.0)
    #     published: 3306    # publicly exposed port
    #     protocol: tcp      # tcp or udp
    #     mode: ingress      # host: For publishing a host port on each node
    security_opt:
      - no-new-privileges:true
    labels:
      com.${container_name}.test.db.description: "is a MySQL database."
    healthcheck:
      disable: false
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 10s
      start_interval: 5s

  ${container_name}_testing_app:
    # deploy:
    #   resources:
    #     limits:
    #       cpus: "2.0"
    #       memory: 128M
    #     reservations:
    #       cpus: "0.25"
    #       memory: 64M
    #   restart_policy:
    #     condition: on-failure
    #     delay: 5s
    #     max_attempts: 3
    #     window: 120s
    restart: unless-stopped #"no", always, unless-stopped.
    logging:
      driver: "json-file"
      options:
        max-size: "1M"
        max-file: "2"
      # driver: syslog
      # options:
      #   syslog-address: "tcp://192.168.0.0:123"
    stop_grace_period: 1m
      # specifies how long Compose must wait when attempting to stop a container.
    container_name: ${container_name}_testing
    image: change_me:latest
    init: false
      # init runs an init process (PID 1) inside the container that forwards signals and reaps processes.
      # Set this option to true to enable this feature for the service.
    pull_policy: if_not_present # always, never, missing, if_not_present, build.
    depends_on:
      ${container_name}_testing_db:
        condition: service_healthy
        restart: true
      ${container_name}_testing_redis:
        condition: service_healthy
    links:
      - ${container_name}_testing_db
    volumes:
      # rw: Read and write access. ro: Read-only access. z: multiple containers. Z: private and unshared
      # - ${container_name}_testing_app:/change_me
      # - /docker/${container_name}/testing/.cert:/change_me
      - /docker/${container_name}/testing/app:/change_me
      # - /docker/${container_name}/testing/config/change_me:/change_me
      # - /docker/${container_name}/testing/log:/change_me
      # - /docker/${container_name}/testing/redis:/change_me
    env_file:
      # adds environment variables to the container based on the file content.
      - .env
      - stack.env
    environment:
      # Any boolean values; "true", "false", "yes", "no", should be enclosed in quotes.
      PUID: "1000" # UserID
      PGID: "1000" # GroupID
      TZ: Europe/Amsterdam
      MYSQL_HOST: \${MYSQL_HOST}
      MYSQL_PORT: \${MYSQL_PORT}
      MYSQL_NAME: \${MYSQL_DATABASE_DB}
      MYSQL_USER: \${MYSQL_USER_DB}
      MYSQL_PASSWORD: \${MYSQL_PASSWORD_DB}
    command: ["change_me"]
    entrypoint: ["change_me"]
      # declares the default entrypoint for the service container.
      # This overrides the ENTRYPOINT instruction from the services Dockerfile.
    domainname: ${container_name}_testing.local
    hostname: ${container_name}_testing
    extra_hosts:
      ${container_name}_testing: "0.0.0.0"
    networks:
      ${container_name}_testing_net:
        ipv4_address: 172.20.0.3
    dns:
      # defines custom DNS servers to set on the container network interface configuration.
      # It can be a single value or a list.
      - 8.8.8.8
      - 8.8.4.4
    dns_search:
      # defines custom DNS search domains to set on container network interface configuration.
      # It can be a single value or a list.
      - dc1.example.com
      - dc2.example.com
    dns_opt:
      # list custom DNS options to be passed to the container’s DNS resolver (/etc/resolv.conf file on Linux).
      - use-vc
      - no-tld-query
    ports:
      - ":/tcp"
      - ":/udp"
    devices:
      # defines a list of device mappings for created containers-
      # in the form of HOST_PATH:CONTAINER_PATH[:CGROUP_PERMISSIONS].
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
      com.docker.compose.project: "${container_name}_testing"
      com.${container_name}.test.description: "change_me."
    healthcheck:
      disable: true
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3
      start_period: 40s
      start_interval: 5s

volumes:
  ${container_name}_testing_db:
    external: true
  ${container_name}_testing_app:
    external: true
EOL

# Add content to .env
cat <<EOL >"$dir_path/.env"
# Database configuration: ROOT
MYSQL_RANDOM_ROOT_PASSWORD="false"
MYSQL_ROOT_PASSWORD_DB="change_me"

# Database configuration: USER
MYSQL_HOST="${container_name}_db"
MYSQL_PORT=3306
MYSQL_DATABASE_DB=${container_name}_db
MYSQL_USER_DB=${container_name}
MYSQL_PASSWORD_DB="change_me"
EOL

# Add content to stack.env
cat <<EOL >"$dir_path/stack.env"
# Database configuration: ROOT
MYSQL_RANDOM_ROOT_PASSWORD="false"
MYSQL_ROOT_PASSWORD_DB="change_me"

# Database configuration: USER
MYSQL_HOST="${container_name}_db"
MYSQL_PORT=3306
MYSQL_DATABASE_DB=${container_name}_db
MYSQL_USER_DB=${container_name}
MYSQL_PASSWORD_DB="change_me"
EOL

# Add content to my.cnf
cat <<EOL >"$dir_path/my.cnf"
#
# The MariaDB/MySQL tools read configuration files in the following order:
# 0. "/etc/mysql/my.cnf" symlinks to this file, reason why all the rest is read.
# 1. "/etc/mysql/mariadb.cnf" (this file) to set global defaults,
# 2. "/etc/mysql/conf.d/*.cnf" to set global options.
# 3. "/etc/mysql/mariadb.conf.d/*.cnf" to set MariaDB-only options.
# 4. "~/.my.cnf" to set user-specific options.
#
# If the same option is defined multiple times, the last one will apply.
#
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.
#
# If you are new to MariaDB, check out https://mariadb.com/kb/en/basic-mariadb-articles/

#
# This group is read both by the client and the server
# use it for options that affect everything
#
[client-server]
# Port or socket location where to connect
# port = 3306
socket = /run/mysqld/mysqld.sock

# Import all .cnf files from configuration directory

!includedir /etc/mysql/mariadb.conf.d/
!includedir /etc/mysql/conf.d/

[mysqld]
# Enable binary logging for replication and point-in-time recovery.
# The log file will be named 'binlog'. You can specify a different name if desired.
log-bin = ${container_name}_binlog

# Set the maximum size for each binary log file. Once the file size reaches this limit,
# a new binary log file is created. A value of 0 means there is no size limit for the binary logs.
max-binlog-size = 100M

# Define the number of days after which binary logs will be automatically purged.
# This helps prevent the binary log files from growing indefinitely.
expire-logs-days = 14

# Optionally, you can set the maximum age for binary logs in seconds, overriding expire-logs-days.
# This option is commented out here, but can be used for more precise control over log expiration.
# binlog-expire-logs-seconds = 1209600  # 14 days in seconds

# Automatically purge relay logs that are no longer needed. Relay logs are used in replication.
# Ensures that unnecessary logs are deleted to free up space and prevent corruption.
relay-log-purge = 1

# Enable relay log recovery to ensure consistency of data after server restarts.
# This ensures that replication can continue from the last valid position.
relay-log-recovery = 1

# Specify the number of slave connections required before purging logs in replication scenarios.
# This value is usually used for managing replication and cleanup.
slave_connections_needed_for_purge = 0

# Set the default transaction isolation level. REPEATABLE-READ ensures that
# transactions can see consistent data throughout their duration without being impacted by others.
transaction-isolation = REPEATABLE-READ

# Enable checksum on binary logs to ensure integrity checks are performed to verify log validity.
# This helps detect any corruption in the binary log files.
binlog-checksum = 1

# Use row-based replication for binary logging. This logs changes at the row level rather than
# the statement level, ensuring that data changes are captured more accurately.
binlog-format = ROW

# Enable compression for binary logs to reduce the amount of disk space consumed by them.
log-bin-compress = 1

# Optionally, you can encrypt binary logs for added security. The encryption option is currently
# disable. It can be enabled for environments requiring higher security.
encrypt-binlog = 0

# Disable native AIO (asynchronous I/O) support for InnoDB. This improves performance
# by allowing multiple disk I/O operations to be performed concurrently.
innodb_use_native_aio = 0

# Disable output of InnoDB status information. In some cases, you may want to disable this to reduce log noise
# or avoid filling up log files with InnoDB-specific status updates.
innodb_status_output = 0
EOL

display_message "Docker container directory structure created in $dir_path."

#!/bin/bash

# Filename: new_docker_container.sh
# Author: GJS (homelab-alpha)
# Date: 2024-05-18T12:09:24+02:00
# Version: 1.0

# Description: This script creates a new Docker container directory structure
# and configuration files based on user input.

# Usage: ./new_docker_container.sh

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script with sudo."
  exit 1
fi

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
base_dir="${docker_base_dir:-/docker}"
dir_path="$base_dir/$container_name"

# Check if directory already exists
if [ -d "$dir_path" ]; then
  display_message "The directory already exists. Choose a different name for the container."
  exit 1
fi

# Create the required directories
declare -a directories=(
  "notes"
  "production/.cert" "production/app" "production/config" "production/db" "production/log" "production/redis"
  "testing/.cert" "testing/app" "testing/config" "testing/db" "testing/log" "testing/redis"
)

for dir in "${directories[@]}"; do
  if ! mkdir -p "$dir_path/$dir"; then
    display_message "Failed to create directory: $dir_path/$dir"
    exit 1
  fi
done

# Create Docker startup files
if ! touch "$dir_path/.dockerignore" "$dir_path/.env" "$dir_path/docker-compose.yml" "$dir_path/Dockerfile" "$dir_path/README.md"; then
  display_message "Failed to create Docker startup files in $dir_path."
  exit 1
fi

# Add content to .dockerignore
cat <<EOL >"$dir_path/.dockerignore"
*/temp*
# Exclude files and directories whose names start with temp in any immediate subdirectory of the root.
# For example, the plain file /somedir/temporary.txt is excluded, as is the directory /somedir/temp.

*/*/temp*
# Exclude files and directories starting with temp from any subdirectory that is two levels below the root.
# For example, /somedir/subdir/temporary.txt is excluded.

temp?
# Exclude files and directories in the root directory whose names are a one-character extension of temp.
# For example, /tempa and /tempb are excluded.
EOL

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
MYSQL_ROOT_PASSWORD_DB=
MYSQL_DATABASE_DB=${container_name}_db
MYSQL_USER_DB=${container_name}
MYSQL_PASSWORD_DB=
EOL

# Add content to docker-compose.yml
cat <<EOL >"$dir_path/docker-compose.yml"
version: "3.9"
networks:
  ${container_name}_net:
    attachable: false # If is set to true: then standalone containers should be able to attach to this network.
    internal: false # when set to true, allows you to create an externally isolated network.
    external: false # If set to true: specifies that this networks lifecycle is maintained outside of that of the application.
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
          #   host1: 192.168.0.2
          #   host2: 192.168.0.3
          #   host3: 192.168.0.4
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
      # rw: Read and write access. ro: Read-only access. z: multiple containers. Z: private and unshared
      # - ${container_name}_db:/change_me
      # - /docker/${container_name}/production/.cert:/change_me
      # - /docker/${container_name}/production/config/change_me:/change_me
      - /docker/${container_name}/production/db:/change_me
      # - /docker/${container_name}/production/log:/change_me
      # - /docker/${container_name}/production/redis:/change_me
    environment:
      # Any boolean values; "true", "false", "yes", "no", should be enclosed in quotes.
      PUID: "1000" # UserID
      PGID: "1000" # GroupID
      TZ: Europe/Amsterdam
      MYSQL_RANDOM_ROOT_PASSWORD: "false"
      MYSQL_ROOT_PASSWORD:
      MYSQL_DATABASE: "${container_name}_db"
      MYSQL_USER: "${container_name}"
      MYSQL_PASSWORD:
    command: ["--transaction-isolation=READ-COMMITTED", "--log-bin=binlog", "--binlog-format=ROW"]
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
      disable: true
      test: ["CMD", "curl", "-f", "http://localhost"]
      interval: 1m30s
      timeout: 10s
      retries: 3
      start_period: 40s
      start_interval: 5s
    secrets:
      - "mysql_root_passwrd"
      - "mysql_db"
      - "mysql_user"
      - "mysql_password"

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
        condition: service_started
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
    environment:
      # Any boolean values; "true", "false", "yes", "no", should be enclosed in quotes.
      PUID: "1000" # UserID
      PGID: "1000" # GroupID
      TZ: Europe/Amsterdam
      MYSQL_HOST: "${container_name}_db"
      MYSQL_PORT: 3306
      MYSQL_NAME: "${container_name}_db"
      MYSQL_USER: "${container_name}"
      MYSQL_PASSWORD:
    command: ["change_me"]
    entrypoint: ["change_me"]
      # declares the default entrypoint for the service container.
      # This overrides the ENTRYPOINT instruction from the services Dockerfile.
    domainname: ${container_name}.my-lan.nl
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
    secrets:
      - "mysql_root_passwrd"
      - "mysql_db"
      - "mysql_user"
      - "mysql_password"
      - "${container_name}_admin_user"
      - "${container_name}_admin_password"

volumes:
  ${container_name}_db:
    external: true
  ${container_name}_app:
    external: true

secrets:
  # If external is set to true, all other attributes apart from name are irrelevant.
  # If Compose detects any other attribute, it rejects the Compose file as invalid.
  mysql_root_passwrd:
    file: change_my.txt # put mysql db name in this file
    external: true
  mysql_db:
    file: change_my.txt # put mysql username in this file
    external: true
  mysql_user:
    file: change_my.txt # put mysql username in this file
    external: true
  mysql_password:
    file: change_my.txt # put mysql password in this file
    external: true
  ${container_name}_admin_user:
    file: change_my.txt # put admin username in this file
    external: true
  ${container_name}_db_admin_password:
    file: change_my.txt # put admin password in this file
    external: true
EOL

# Add content to Dockerfile
cat <<EOL >"$dir_path/Dockerfile"
EOL

# Add content to READEME.md
cat <<EOL >"$dir_path/README.md"
.. ${container_name}::
.
├── notes                - Note files and information about the configuration.
│
├── production           - Configuration files and data for the production environment.
│   ├── .cert            - SSL certificates for secure connections.
│   ├── app              - Application files.
│   ├── config           - Configuration files for the application.
│   ├── db               - Database files.
│   ├── log              - Log files.
│   └── redis            - Redis database files.
│
├── testing              - Configuration files and data for the testing environment.
│   ├── .cert            - SSL certificates for secure connections.
│   ├── app              - Application files.
│   ├── config           - Configuration files for the application.
│   ├── db               - Database files.
│   └── log              - Log files.
│
├── .dockerignore        - Excludes files from Docker builds.
├── .env                 - Environment variables for the Docker containers.
├── docker-compose.yml   - Docker Compose configuration.
├── Dockerfile           - Docker container build instructions.
└── README.md            - Instructions and information about the project.
\`\`\`

## Customization

- Update placeholder values (change_me, USER, ROLE, etc.) in the Docker Compose files with your specific configurations.
- Modify the .env file with API keys, secrets, and MySQL configurations.

## Author

GJS (homelab-alpha)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.

[LICENSE]: https://github.com/homelab-alpha/shell-script/blob/main/LICENSE.md
EOL

display_message "Docker container directory structure created in $dir_path."

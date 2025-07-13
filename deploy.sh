#!/bin/bash

# Function to generate random strings
generate_random() {
    local length=$1
    LC_ALL=C tr -dc 'A-Za-z0-9!#$%&()*+,-./:;<=>?@[\]^_{|}~' </dev/urandom | head -c "$length"
    echo
}

# Function to validate project name
validate_project_name() {
    local name=$1
    # Check if name is empty
    if [[ -z "$name" ]]; then
        echo "Project name cannot be empty."
        return 1
    fi
    # Check for invalid characters
    if [[ "$name" =~ [^a-zA-Z0-9_-] ]]; then
        echo "Project name can only contain letters, numbers, hyphens and underscores."
        return 1
    fi
    return 0
}

# Function to get server IP addresses
get_server_ips() {
    echo "Server IP Addresses:"
    # Try different methods to get IP addresses
    {
        ip -o -4 addr show | awk '{print $4}' | cut -d/ -f1
        hostname -I 2>/dev/null
        ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
    } | sort -u | while read -r ip; do
        echo " - $ip"
    done
}

# Get project name
while true; do
    read -p "Enter project name: " project_name
    project_name=$(echo "$project_name" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
    if validate_project_name "$project_name"; then
        break
    fi
done

# Convert to lowercase for container names
project_lower=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')

# Generate random credentials
root_password=$(generate_random 32)
db_name=$(generate_random 16)
db_user=$(generate_random 16)
db_password=$(generate_random 32)
wp_prefix="$(generate_random 8 | tr -dc 'a-z0-9')_"
wp_port=$((8000 + RANDOM % 1000))

# Create .env file
cat > .env <<EOF
# MARIADB
# Nombre del contenedor de la base de datos
CONTAINERDB=${project_lower}_md
# Contraseña del usuario Root de MariaDB
ROOTDB=${root_password}
# Nombre de la base de datos
DATABASE=${db_name}
# Usuario de la Base de datos
USERDB=${db_user}
# Contraseña del usuario de la base de datos
USERPDB=${db_password}


# WORDPRESS
# Nombre del contenedor de Wordpress
CONTAINERWP=${project_lower}_wp
# Prefijo de las tablas de Wordpress
PREFIXWP=${wp_prefix}
# Puerto por el que escuchará el contenedor
PORTWP=${wp_port}
EOF

# Create docker-compose.yml file
cat > docker-compose.yml <<EOF
version: '3.8'

services:
  ${project_lower}_md:
    image: mariadb:latest
    container_name: \${CONTAINERDB}
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: \${ROOTDB}
      MYSQL_DATABASE: \${DATABASE}
      MYSQL_USER: \${USERDB}
      MYSQL_PASSWORD: \${USERPDB}
    volumes:
      - ${project_lower}_db_data:/var/lib/mysql
    networks:
      - ${project_lower}_net

  ${project_lower}_wp:
    depends_on:
      - ${project_lower}_md
    image: wordpress:latest
    container_name: \${CONTAINERWP}
    restart: always
    ports:
      - "\${PORTWP}:80"
    environment:
      WORDPRESS_DB_HOST: \${CONTAINERDB}
      WORDPRESS_DB_USER: \${USERDB}
      WORDPRESS_DB_PASSWORD: \${USERPDB}
      WORDPRESS_DB_NAME: \${DATABASE}
      WORDPRESS_TABLE_PREFIX: \${PREFIXWP}
    volumes:
      - ${project_lower}_wp_data:/var/www/html
    networks:
      - ${project_lower}_net

volumes:
  ${project_lower}_db_data:
  ${project_lower}_wp_data:

networks:
  ${project_lower}_net:
    name: ${project_lower}_net
EOF

echo ""
echo "================================================"
echo "Setup complete!"
echo "Created .env and docker-compose.yml files."
echo ""
echo "You can start the containers with: docker-compose up -d"
echo ""
get_server_ips
echo ""
echo "WordPress will be available at:"
echo " - http://localhost:${wp_port}"
echo " - Or via your server IP at port ${wp_port}"
echo "================================================"

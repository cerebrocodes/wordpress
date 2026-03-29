#!/usr/bin/env bash
#
# create-docker-compose.sh - Generate docker-compose.yml for WordPress site
#
# DESCRIPTION:
#   Generates a docker-compose.yml file with MariaDB, WordPress, and optional
#   WP-CLI services. Uses environment variables exported by main.sh.
#
# USAGE:
#   ./create-docker-compose.sh [TARGET_DIR]
#
# ARGUMENTS:
#   TARGET_DIR    Target directory where docker-compose.yml will be created
#                 (defaults to current directory)
#
# DEPENDS ON:
#   PROJECT_NAME, ROOTDBP, USERDB, USERDBP, PREFIXWP, PORTWP, NETWORK_NAME
#
#==============================================================================

set -euo pipefail

# Check if this script should run
if [[ "${GENERATE_DOCKER_COMPOSE:-false}" != "true" ]]; then
    exit 0
fi

# Set target directory
TARGET_DIR="${1:-.}"

# Generate docker-compose.yml
cat > "$TARGET_DIR/docker-compose.yml" <<EOF
services:
  ${PROJECT_NAME}_dbs:
    image: ${MARIADB_IMG:-mariadb:11.6.2}
    restart: always
    container_name: ${PROJECT_NAME}_db
    environment:
      MYSQL_ROOT_PASSWORD: \${ROOTDBP}
      MYSQL_DATABASE: \${DBNAME}_${PROJECT_NAME}
      MYSQL_USER: \${USERDB}
      MYSQL_PASSWORD: \${USERDBP}
    security_opt:
      - apparmor:unconfined
    volumes:
      - ${PROJECT_NAME}_dbv:/var/lib/mysql
    networks:
      - ${NETWORK_NAME:-${PROJECT_NAME}_nw}

  ${PROJECT_NAME}_wps:
    build: .
    restart: always
    container_name: ${PROJECT_NAME}_wp
    environment:
      WORDPRESS_DB_HOST: ${PROJECT_NAME}_db
      WORDPRESS_DB_NAME: \${DBNAME}_${PROJECT_NAME}
      WORDPRESS_DB_USER: \${USERDB}
      WORDPRESS_DB_PASSWORD: \${USERDBP}
      WORDPRESS_TABLE_PREFIX: \${PREFIXWP}
      WORDPRESS_CONFIG_EXTRA: "define('WP_MEMORY_LIMIT', '${WP_MEMORY_LIMIT}'); define('WP_MAX_MEMORY_LIMIT', '${WP_MAX_MEMORY_LIMIT}');"
    ports:
      - "\${PORTWP}:80"
    security_opt:
      - apparmor:unconfined
    volumes:
      - ${PROJECT_NAME}_wpv:/var/www/html/
      - ./wp-content:/var/www/html/wp-content
      - /mnt/nextcloud-media:/nextcloud-media:ro
      - ./php-custom.ini:/usr/local/etc/php/conf.d/php-custom.ini
    depends_on:
      - ${PROJECT_NAME}_dbs
    networks:
      - ${PROJECT_NAME}_nw

  ${PROJECT_NAME}_wpcli:
    image: wordpress:cli
    container_name: ${PROJECT_NAME}_wpcli
    environment:
      WORDPRESS_DB_HOST: ${PROJECT_NAME}_db
      WORDPRESS_DB_NAME: \${DBNAME}_${PROJECT_NAME}
      WORDPRESS_DB_USER: \${USERDB}
      WORDPRESS_DB_PASSWORD: \${USERDBP}
      WORDPRESS_TABLE_PREFIX: \${PREFIXWP}
    security_opt:
      - apparmor:unconfined
    user: "33:33"
    working_dir: /var/www/html
    command: tail -f /dev/null
    volumes:
      - ${PROJECT_NAME}_wpv:/var/www/html
      - /mnt/nextcloud-media:/nextcloud-media:ro
    depends_on:
      - ${PROJECT_NAME}_wps
    networks:
      - ${PROJECT_NAME}_nw

volumes:
  ${PROJECT_NAME}_dbv:
  ${PROJECT_NAME}_wpv:

networks:
  ${PROJECT_NAME}_nw:
    driver: bridge
EOF

echo "Created docker-compose.yml in $TARGET_DIR"

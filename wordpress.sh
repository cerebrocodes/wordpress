#!/usr/bin/env bash
#
# wordpress.sh - WordPress Site Generator
#
# DESCRIPTION:
#
#
##
# AUTHOR:
#   Marcos Rubén <contacto@marcosruben.com>
#
# DATE:
#   2026-03-28
#
# VERSION:
#   1.0.0
#
# LICENSE:
#   MIT License
#
#==============================================================================


# ============================================================================
# PROJECT CONFIGURATION
# ============================================================================
PROJECT_NAME="wordpress_project"
DOMAIN="wordpress_project.com"

# Variable length
ROOTDBPLength=23
USERDBLength=11
USERDBPLength=23
DBNAMELength=11
PREFIXWPLength=7

# Docker Images
MARIADB_IMG="mariadb:11.6.2"
WORDPRESS_IMG="wordpress:latest"
WPCLI_IMG="wordpress:cli"

# ============================================================================
# MEMORY Configuration
# ============================================================================

# PHP
PHP_UPLOAD_SIZE_MB=64
PHP_POST_SIZE_MB=$((PHP_UPLOAD_SIZE_MB + (PHP_UPLOAD_SIZE_MB / 10)))
PHP_MEMORY_MB=512
PHP_MAX_EXECUTION_TIME=300
PHP_MAX_INPUT_TIME=300

# Convert to strings with "M" suffix for config files
PHP_UPLOAD_MAX_FILESIZE="${PHP_UPLOAD_SIZE_MB}M"
PHP_POST_MAX_SIZE="${PHP_POST_SIZE_MB}M"
PHP_MEMORY_LIMIT="${PHP_MEMORY_MB}M"

# NGINX

NGINX_SIZE_MB=$((PHP_POST_SIZE_MB + (PHP_POST_SIZE_MB / 10))) 
NGINX_CLIENT_MAX_BODY_SIZE="${NGINX_SIZE_MB}M"

# WORDPRESS
WP_MEMORY_MB=$((PHP_UPLOAD_SIZE_MB * 8))
WP_MAX_MEMORY_MB=$((WP_MEMORY_MB * 2))

# Convert to strings with "M" suffix
WP_MEMORY_LIMIT="${WP_MEMORY_MB}M"
WP_MAX_MEMORY_LIMIT="${WP_MAX_MEMORY_MB}M"


# ============================================================================
# FILES CREATION
# ============================================================================

# Flags to control which components to generate
GENERATE_DOCKER_COMPOSE=true
GENERATE_ENV=true
GENERATE_DOCKERFILE=true
GENERATE_PHP_INI=true
GENERATE_WP_CLI=true
GENERATE_NGINX_CONF=true

# ============================================================================
# Display Results
# ============================================================================

echo "=== Generated Configuration ==="
echo ""
echo "PHP:"
echo "  upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}"
echo "  post_max_size = ${PHP_POST_MAX_SIZE}"
echo "  memory_limit = ${PHP_MEMORY_LIMIT}"
echo "  max_execution_time = ${PHP_MAX_EXECUTION_TIME}"
echo "  max_input_time = ${PHP_MAX_INPUT_TIME}"
echo ""
echo "Nginx:"
echo "  client_max_body_size = ${NGINX_CLIENT_MAX_BODY_SIZE}"
echo ""
echo "WordPress:"
echo "  WP_MEMORY_LIMIT = ${WP_MEMORY_LIMIT}"
echo "  WP_MAX_MEMORY_LIMIT = ${WP_MAX_MEMORY_LIMIT}"


#!/usr/bin/env bash
#
# create-dockerfile.sh - Generate Dockerfile for WordPress with custom configuration
#
# DESCRIPTION:
#   Creates a Dockerfile that builds a WordPress image with custom
#   php.ini configuration and additional extensions.
#
# USAGE:
#   ./create-dockerfile.sh [TARGET_DIR]
#
# DEPENDS ON:
#   PHP_EXTENSIONS (optional, defined in wordpress.def)
#
#==============================================================================

set -euo pipefail

# Check if this script should run
if [[ "${GENERATE_DOCKERFILE:-false}" != "true" ]]; then
    exit 0
fi

# Set target directory
TARGET_DIR="${1:-.}"

# Set default PHP extensions if not defined
PHP_EXTENSIONS="${PHP_EXTENSIONS:-mysqli pdo_mysql gd imagick zip opcache}"

# Generate Dockerfile
cat > "$TARGET_DIR/Dockerfile" <<EOF
# Dockerfile for WordPress with custom configuration
FROM wordpress:latest

# Set working directory
WORKDIR /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html
EOF

echo "Created Dockerfile in $TARGET_DIR"
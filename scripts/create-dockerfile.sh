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

# Install additional PHP extensions
RUN apt update && apt install -y \\
    libpng-dev \\
    libjpeg-dev \\
    libfreetype6-dev \\
    libmagickwand-dev \\
    libzip-dev\\
    && docker-php-ext-configure gd --with-freetype --with-jpeg \\
    && docker-php-ext-install -j\$(nproc) \\
    mysqli \\
    pdo_mysql \\
    gd \\
    zip \\
    opcache \\
    && pecl install imagick \\
    && docker-php-ext-enable imagick \\
    && apt clean \\
    && rm -rf /var/lib/apt/lists/*

# Copy custom php.ini configuration
COPY php-custom.ini /usr/local/etc/php/conf.d/php-custom.ini

# Set recommended WordPress settings
RUN { \\
    echo 'opcache.memory_consumption=128'; \\
    echo 'opcache.interned_strings_buffer=8'; \\
    echo 'opcache.max_accelerated_files=4000'; \\
    echo 'opcache.revalidate_freq=2'; \\
    echo 'opcache.fast_shutdown=1'; \\
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# Set working directory
WORKDIR /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html
EOF

echo "Created Dockerfile in $TARGET_DIR"
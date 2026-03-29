#!/usr/bin/env bash
set -euo pipefail

echo "DEBUG: create-env.sh started"
echo "DEBUG: GENERATE_ENV = ${GENERATE_ENV:-not set}"

if [[ "${GENERATE_ENV:-false}" != "true" ]]; then
    echo "DEBUG: Exiting because GENERATE_ENV is not true"
    exit 0
fi

echo "DEBUG: Continuing with file creation"
TARGET_DIR="${1:-.}"
echo "DEBUG: TARGET_DIR = $TARGET_DIR"

cat > "$TARGET_DIR/.env" <<EOF

PROJECT_NAME=$(PROJECT_NAME)

# MariaDB Configuration
CONTAINERDB=${PROJECT_NAME}_db
ROOTDBP=${ROOTDBP}
DBNAME=${DBNAME}
USERDB=${USERDB}
USERDBP=${USERDBP}

# WordPress Configuration
CONTAINERWP=${PROJECT_NAME}_wp
PREFIXWP=${PREFIXWP}
PORTWP=${PORTWP}

# Docker Network
NETWORK=${PROJECT_NAME}_nw}

# Docker Volumes
VOLUMEDB=${PROJECT_NAME}_dbv
VOLUMEWP=${PROJECT_NAME}_wpv
EOF

echo "Created .env in $TARGET_DIR"
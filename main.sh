#!/usr/bin/env bash
#
# main.sh - WordPress Site Generator Orchestrator
#
# DESCRIPTION:
#   Main orchestration script for automated WordPress site generation.
#   Loads configuration from a definition file, generates random secure
#   values for database credentials, and executes modular generation
#   scripts to create a complete Docker-based WordPress environment.
#
# USAGE:
#   ./main.sh [DEFINITION_FILE]
#
#   If no definition file is provided, defaults to 'wordpress.sh' in the
#   same directory.
#
# ARGUMENTS:
#   DEFINITION_FILE    Optional path to configuration file (default: wordpress.sh)
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

# set -e	Exit immediately if any command exits with a non-zero status
# set -u	Treat unset variables as an error
# set -o pipefail	Pipeline failures propagate
set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to that directory to ensure consistent paths
cd "$SCRIPT_DIR"


# If the script is called with an argument (e.g., ./main.sh custom.def),
# it uses that file Otherwise, it defaults to wordpress.sh
# in the same directory as main.sh
DEF_FILE="${1:-wordpress.sh}"

# Load the Definition file, wordpress.sh as default.
source "$DEF_FILE"

#===============================================================================
# GENERATE RANDOM DATABASE VALUES
#===============================================================================

# root password 
ROOTDBP=$(openssl rand -base64 ${ROOTDBPLength} | tr -dc 'a-zA-Z0-9!@#$%^&*()_+')
# user name
USERDB="$(openssl rand -base64 ${USERDBLength} | tr -dc 'a-zA-Z0-9' | head -c ${USERDBLength})_${PROJECT_NAME}"
# user password
USERDBP="$(openssl rand -base64 ${USERDBPLength} | tr -dc 'a-zA-Z0-9' | head -c ${USERDBPLength})_${PROJECT_NAME}"
# database name
DBNAME="$(openssl rand -base64 ${DBNAMELength} | tr -dc 'a-zA-Z0-9' | head -c ${DBNAMELength})_${PROJECT_NAME}"
# table prefix
PREFIXWP="$(openssl rand -base64 ${PREFIXWPLength} | tr -dc 'a-zA-Z0-9' | head -c ${PREFIXWPLength})_${PROJECT_NAME}"
# radom port from 1024 to 49151
PORTWP=$(shuf -i 1024-49151 -n 1) 

#===============================================================================
# CREATING PROJECT FILES
#===============================================================================

# Export for child scripts
 export PROJECT_NAME ROOTDBP USERDB USERDBP PREFIXWP PORTWP MARIADB_IMG DBNAME PHP_UPLOAD_MAX_FILESIZE PHP_POST_MAX_SIZE PHP_MEMORY_LIMIT PHP_MAX_EXECUTION_TIME PHP_MAX_INPUT_TIME NGINX_CLIENT_MAX_BODY_SIZE WP_MEMORY_LIMIT WP_MAX_MEMORY_LIMIT

# Load the Definition file with automatic export
set -a
source "$DEF_FILE"
set +a


# Create project directory
TARGET_DIR="/opt/${PROJECT_NAME}"
mkdir -p "$TARGET_DIR"
cd "$TARGET_DIR"


# Execute generation scripts
echo "Looking for scripts in $SCRIPT_DIR/scripts/..."
for script in "$SCRIPT_DIR/scripts"/*.sh; do
    echo "Found: $script"
    if [[ -x "$script" ]]; then
        echo "Running $script..."
        "$script" "$TARGET_DIR"
    else
        echo "Not executable: $script"
    fi
done
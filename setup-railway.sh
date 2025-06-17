#!/bin/bash

# Railway Setup Script for WildDuck Email Suite

# Enable logging
LOG_FILE="/tmp/wildduck-railway-setup.log"
DOCKER_LOG_FILE="/tmp/wildduck-docker.log"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Error log function
error_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE"
}

# Docker log function
docker_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] DOCKER: $1" | tee -a "$DOCKER_LOG_FILE"
}

# Initialize log files
touch "$LOG_FILE"
touch "$DOCKER_LOG_FILE"

log "Setting up WildDuck Email Suite for Railway deployment..."

# Get environment variables from Railway
MAILDOMAIN=${MAILDOMAIN:-${RAILWAY_PUBLIC_DOMAIN}}
HOSTNAME=${HOSTNAME:-${RAILWAY_PUBLIC_DOMAIN}}
FULL_SETUP=${FULL_SETUP:-true}

log "DOMAINNAME: $MAILDOMAIN, HOSTNAME: $HOSTNAME, FULL_SETUP: $FULL_SETUP"

# Create config directory if it doesn't exist
if [ ! -e ./config-generated/config-generated ]; then 
    log "Copying default configuration into ./config-generated/config-generated"
    mkdir -p config-generated/config-generated
    cp -r ./default-config/* ./config-generated/config-generated/
    if [ $? -ne 0 ]; then
        error_log "Failed to copy default configuration"
    fi
fi

# Update configuration files with Railway environment
log "Updating configuration for Railway deployment..."

# Detect OS type for sed compatibility
if [[ "$(uname)" == "Darwin" ]]; then
    log "Detected macOS, using compatible sed command"
    SED_CMD="sed -i ''"
else
    log "Using standard sed command for Linux"
    SED_CMD="sed -i"
 fi

# Update WildDuck configuration
if [ -f ./config-generated/config-generated/wildduck/default.toml ]; then
    log "Updating WildDuck configuration"
    $SED_CMD "s/localhost/$HOSTNAME/g" ./config-generated/config-generated/wildduck/default.toml
    if [ $? -ne 0 ]; then
        error_log "Failed to update hostname in WildDuck configuration"
    fi
    $SED_CMD "s/127.0.0.1/0.0.0.0/g" ./config-generated/config-generated/wildduck/default.toml
    if [ $? -ne 0 ]; then
        error_log "Failed to update IP in WildDuck configuration"
    fi
else
    error_log "WildDuck configuration file not found"
fi

# Update Haraka configuration
if [ -f ./config-generated/config-generated/haraka/wildduck.yaml ]; then
    log "Updating Haraka configuration"
    $SED_CMD "s/localhost/$HOSTNAME/g" ./config-generated/config-generated/haraka/wildduck.yaml
    if [ $? -ne 0 ]; then
        error_log "Failed to update Haraka configuration"
    fi
else
    error_log "Haraka configuration file not found"
fi

# Update Zone-MTA configuration
if [ -f ./config-generated/config-generated/zone-mta/zonemta.toml ]; then
    log "Updating Zone-MTA configuration"
    $SED_CMD "s/localhost/$HOSTNAME/g" ./config-generated/config-generated/zone-mta/zonemta.toml
    if [ $? -ne 0 ]; then
        error_log "Failed to update Zone-MTA configuration"
    fi
else
    error_log "Zone-MTA configuration file not found"
fi

# Update webmail configuration
if [ -f ./config-generated/config-generated/wildduck-webmail/default.toml ]; then
    log "Updating webmail configuration"
    $SED_CMD "s/localhost/$HOSTNAME/g" ./config-generated/config-generated/wildduck-webmail/default.toml
    if [ $? -ne 0 ]; then
        error_log "Failed to update hostname in webmail configuration"
    fi
    $SED_CMD "s/127.0.0.1/0.0.0.0/g" ./config-generated/config-generated/wildduck-webmail/default.toml
    if [ $? -ne 0 ]; then
        error_log "Failed to update IP in webmail configuration"
    fi
else
    error_log "Webmail configuration file not found"
fi

log "Configuration updated for Railway deployment"
log "Starting services..."

# Collect Docker container information for logging
docker_log "Listing Docker containers:"
docker ps -a 2>&1 | tee -a "$DOCKER_LOG_FILE" || error_log "Failed to list Docker containers"

# Start the main application
if [ $# -eq 0 ]; then
    log "No arguments provided, using default command from Dockerfile"
    # Capture Docker logs
    docker_log "Starting Docker services with default command"
    # No arguments provided, use the default command from Dockerfile
    exec "$@" 2>&1 | tee -a "$DOCKER_LOG_FILE"
else
    log "Arguments provided, running server.js with args: $@"
    # Capture Docker logs
    docker_log "Starting server.js with arguments: $@"
    # Arguments were provided, run the server
    node server.js 2>&1 | tee -a "$DOCKER_LOG_FILE"
fi

# This part will only execute if the above commands fail
error_log "Service startup failed"
exit 1
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

# Check if docker command exists before trying to use it
if command -v docker &> /dev/null; then
    docker_log "Listing Docker containers:"
    docker ps -a 2>&1 | tee -a "$DOCKER_LOG_FILE" || error_log "Failed to list Docker containers"
else
    log "Docker command not found, skipping container listing"
fi

# Create necessary directories for configuration if they don't exist
log "Ensuring configuration directories exist"
mkdir -p ./config-generated/config-generated/wildduck
mkdir -p ./config-generated/config-generated/haraka
mkdir -p ./config-generated/config-generated/zone-mta
mkdir -p ./config-generated/config-generated/wildduck-webmail

# Copy default configuration files if they don't exist
if [ ! -f ./config-generated/config-generated/wildduck/default.toml ] && [ -f ./default-config/wildduck/default.toml ]; then
    log "Copying WildDuck default configuration"
    cp ./default-config/wildduck/default.toml ./config-generated/config-generated/wildduck/
fi

if [ ! -f ./config-generated/config-generated/haraka/wildduck.yaml ] && [ -f ./default-config/haraka/wildduck.yaml ]; then
    log "Copying Haraka default configuration"
    cp ./default-config/haraka/wildduck.yaml ./config-generated/config-generated/haraka/
fi

if [ ! -f ./config-generated/config-generated/zone-mta/zonemta.toml ] && [ -f ./default-config/zone-mta/zonemta.toml ]; then
    log "Copying Zone-MTA default configuration"
    cp ./default-config/zone-mta/zonemta.toml ./config-generated/config-generated/zone-mta/
fi

if [ ! -f ./config-generated/config-generated/wildduck-webmail/default.toml ] && [ -f ./default-config/wildduck-webmail/default.toml ]; then
    log "Copying webmail default configuration"
    cp ./default-config/wildduck-webmail/default.toml ./config-generated/config-generated/wildduck-webmail/
fi

# Check if we're running in Railway environment
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
    log "Running in Railway environment with domain: $RAILWAY_PUBLIC_DOMAIN"
fi

# Start the main application
if [ $# -eq 0 ]; then
    log "No arguments provided, using default command from Dockerfile"
    
    # Check if we should run node directly instead of using Docker
    if [ -f "./server.js" ]; then
        log "Starting server.js directly"
        node server.js 2>&1 | tee -a "$LOG_FILE"
        SERVER_EXIT_CODE=$?
        
        if [ $SERVER_EXIT_CODE -ne 0 ]; then
            error_log "Server exited with code $SERVER_EXIT_CODE"
        fi
    else
        error_log "server.js not found, cannot start application"
        exit 1
    fi
else
    log "Arguments provided, running with args: $@"
    
    # Execute the provided command
    "$@" 2>&1 | tee -a "$LOG_FILE"
    CMD_EXIT_CODE=$?
    
    if [ $CMD_EXIT_CODE -ne 0 ]; then
        error_log "Command exited with code $CMD_EXIT_CODE"
    fi
fi

# Log completion
log "Setup script completed"
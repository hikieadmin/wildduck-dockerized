#!/bin/bash

# Railway Setup Script for WildDuck Email Suite

echo "Setting up WildDuck Email Suite for Railway deployment..."

# Get environment variables from Railway
MAILDOMAIN=${MAILDOMAIN:-${RAILWAY_PUBLIC_DOMAIN}}
HOSTNAME=${HOSTNAME:-${RAILWAY_PUBLIC_DOMAIN}}
FULL_SETUP=${FULL_SETUP:-true}

echo "DOMAINNAME: $MAILDOMAIN, HOSTNAME: $HOSTNAME, FULL_SETUP: $FULL_SETUP"

# Create config directory if it doesn't exist
if [ ! -e ./config ]; then 
    echo "Copying default configuration into ./config"
    mkdir -p config
    cp -r ./default-config/* ./config/
fi

# Update configuration files with Railway environment
echo "Updating configuration for Railway deployment..."

# Update WildDuck configuration
if [ -f ./config/wildduck/default.toml ]; then
    sed -i "s/localhost/$HOSTNAME/g" ./config/wildduck/default.toml
    sed -i "s/127.0.0.1/0.0.0.0/g" ./config/wildduck/default.toml
fi

# Update Haraka configuration
if [ -f ./config/haraka/wildduck.yaml ]; then
    sed -i "s/localhost/$HOSTNAME/g" ./config/haraka/wildduck.yaml
fi

# Update Zone-MTA configuration
if [ -f ./config/zone-mta/zonemta.toml ]; then
    sed -i "s/localhost/$HOSTNAME/g" ./config/zone-mta/zonemta.toml
fi

# Update webmail configuration
if [ -f ./config/wildduck-webmail/default.toml ]; then
    sed -i "s/localhost/$HOSTNAME/g" ./config/wildduck-webmail/default.toml
    sed -i "s/127.0.0.1/0.0.0.0/g" ./config/wildduck-webmail/default.toml
fi

echo "Configuration updated for Railway deployment"
echo "Starting services..."

# Start the main application
exec "$@"
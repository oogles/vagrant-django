#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/vagrant_provision_settings.sh

echo " "
echo " --- Setup app directory structure (at $APP_DIR) ---"

# Create the directory structure to store various project related files -
# required by the rest of the provisioning. Use -p to only create the directories
# if they don't already exist, and to create any necessary parent directories.
mkdir -p "$APP_DIR/media/"

if [[ "$DEBUG" -eq 0 ]]; then
    mkdir -p "$APP_DIR/static/"
    mkdir -p "$APP_DIR/logs/nginx/"
    mkdir -p "$APP_DIR/logs/gunicorn/"
fi

# Set ownership of everything in the app directory
chown www-data:www-data -R "$APP_DIR"

echo "Done"

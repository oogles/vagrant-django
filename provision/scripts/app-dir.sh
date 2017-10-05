#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

echo " "
echo " --- Setup app directory structure (at $APP_DIR) ---"

# Create the directory structure to store various project related files -
# required by the rest of the provisioning. Use -p to only create the directories
# if they don't already exist, and to create any necessary parent directories.
mkdir -p "$APP_DIR/media/"
mkdir -p "$APP_DIR/conf/"
mkdir -p "$APP_DIR/logs/"

if [[ "$DEBUG" -eq 0 ]]; then
    mkdir -p "$APP_DIR/static/"
fi

# Set ownership of everything in the app directory
chown www-data:www-data -R "$APP_DIR"

# Allow group writes to the app directory (the webmaster user is in the www-data group)
chmod g+w "$APP_DIR"

echo "Done"

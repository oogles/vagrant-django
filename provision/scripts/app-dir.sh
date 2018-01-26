#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

echo " "
echo " --- Setup app directory structure (at $APP_DIR) ---"

# Ensure group read/write access to the app directory (the webmaster user is in
# the www-data group)
chmod 775 "$APP_DIR"

# Create the directory structure to store various project related files -
# required by the rest of the provisioning. Use -p to only create the directories
# if they don't already exist.
mkdir -p -m 775 "$APP_DIR/media/"
mkdir -p -m 775 "$APP_DIR/conf/"
mkdir -p -m 775 "$APP_DIR/logs/"

if [[ "$DEBUG" -eq 0 ]]; then
    mkdir -p -m 775 "$APP_DIR/static/"
fi

# Set ownership of everything in the app directory
chown www-data:www-data -R "$APP_DIR"

# Update the webmaster user's profile to automatically change to the project
# source directory when they SSH in
if ! grep -Fxq "cd $SRC_DIR" /home/webmaster/.profile ; then
    echo -e "\n# Change into the $PROJECT_NAME source directory by default\ncd $SRC_DIR" >> /home/webmaster/.profile
fi

echo "Done"

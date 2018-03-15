#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh
source /tmp/versions.sh

echo " "
echo " --- Install node.js/npm ---"

# Install node and update npm
curl -sL "https://deb.nodesource.com/setup_$NODE_VERSION.x" | bash -
apt-get -qq install nodejs
npm install npm -g --quiet

# Get node_modules out of the shared folder.
# This avoids multiple issues when using a Windows host.
# NOTE: The name of the linked directory seems to want to be "node_modules".
# Anything else causes issues.
NODE_MODULES_PATH="$APP_DIR/node_modules"
NODE_LINK_PATH="$SRC_DIR/node_modules"

if [[ ! -d "$NODE_MODULES_PATH" ]]; then
    mkdir "$NODE_MODULES_PATH"
    chown www-data:www-data "$NODE_MODULES_PATH"
    chmod g+w "$NODE_MODULES_PATH"
fi

# Create a symlink to the relocated node_modules directory.
# Remove the link first if it already exists, just to ensure there will be no
# issues with symlinks hanging around from previous builds of the VM.
if [[ -L "$NODE_LINK_PATH" ]]; then
    rm "$NODE_LINK_PATH"
fi

ln -s "$NODE_MODULES_PATH" "$NODE_LINK_PATH"

## Install project dependencies
echo " "
echo " --- Install node.js dependencies ---"
if [[ "$DEBUG" -eq 1 ]]; then
    su - webmaster -c "cd $SRC_DIR && npm install --quiet"
else
    su - webmaster -c "cd $SRC_DIR && npm install --production --quiet"
fi

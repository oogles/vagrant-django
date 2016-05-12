#!/usr/bin/env bash

echo " "
echo " --- Install node.js/npm ---"

DEBUG="$1"

# Install node and update npm
apt-get -qq install nodejs
npm install npm -g --quiet

# Get node_modules out of the shared folder.
# This avoids multiple issues when using a Windows host.
# NOTE: The name of the linked directory seems to want to be "node_modules".
# Anything else causes issues.
NODE_MODULES_PATH="/home/vagrant/node_modules"
NODE_LINK_PATH="/vagrant/node_modules"

if [[ ! -d "$NODE_MODULES_PATH" ]]; then
    mkdir "$NODE_MODULES_PATH"
    chown vagrant:vagrant "$NODE_MODULES_PATH"
fi

# Create a symlink to the relocated node_modules directory.
# Remove the link first if it already exists, just to ensure there will be no
# issues with symlinks hanging around from previous builds of the VM.
if [[ -L "$NODE_LINK_PATH" ]]; then
    rm "$NODE_LINK_PATH"
fi

ln -s "$NODE_MODULES_PATH" "$NODE_LINK_PATH"

# Install project dependencies
echo " "
echo " --- Install node.js dependencies ---"
if [[ "$DEBUG" -eq 1 ]]; then
    su - vagrant -c "cd /vagrant/ && npm install --quiet"
else
    su - vagrant -c "cd /vagrant/ && npm install --production --quiet"
fi

#!/usr/bin/env bash

echo " "
echo " --- Install node.js/npm ---"

DEBUG="$2"

# Install node and update npm
apt-get -qq install nodejs
npm install npm -g --quiet

# Get node_modules out of the shared folder.
# This avoids multiple issues when using a Windows host.
# NOTE: The name of the linked directory seems to want to be "node_modules".
# Anything else causes issues.
NODE_MODULES_PATH="/home/vagrant/node_modules"

if [[ ! -d "$NODE_MODULES_PATH" ]]; then
    su - vagrant -c "mkdir -p $NODE_MODULES_PATH"
fi

if [[ ! -L /vagrant/node_modules ]]; then
    su - vagrant -c "ln -s $NODE_MODULES_PATH /vagrant/node_modules"
fi

# Install project dependencies
echo " "
echo " --- Install node.js dependencies ---"
if [[ "$DEBUG" -eq 1 ]]; then
    su - vagrant -c "cd /vagrant/ && npm install --quiet"
else
    su - vagrant -c "cd /vagrant/ && npm install --production --quiet"
fi

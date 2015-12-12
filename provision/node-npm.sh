#!/usr/bin/env bash

echo " "
echo " --- Node.js/npm ---"

PROJECT_NAME="$1"

# Install node and update npm
apt-get install -y nodejs
npm install npm -g

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
if [[ -f /vagrant/package.json ]]; then
    echo " "
    echo " --- Node.js dependencies ---"
	su - vagrant -c "cd /vagrant/ && npm install"
fi

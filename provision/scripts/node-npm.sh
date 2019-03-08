#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/settings.sh

echo " "
echo " --- Install node.js & friends ---"

echo " "
echo "Installing node..."
# Install node and update npm
curl -sL "https://deb.nodesource.com/setup_$NODE_VERSION.x" | bash -
apt-get -qq install nodejs

echo " "
echo "Updating npm..."
npm install npm -g --quiet

echo " "
echo "Symlinking node_modules..."
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

# If a package-scripts.js file is present, also install nps as an alternative
# to "npm run" as a task runner
if [[ -f "$SRC_DIR/package-scripts.js" ]]; then
    echo " "
    echo "Installing nps..."
    npm install -g --quiet nps

    # Configure command autocompletion for nps
    if ! grep -Fxq "###-begin-nps-completions-###" /home/webmaster/.bashrc ; then
        nps completion >> /home/webmaster/.bashrc
    fi
fi

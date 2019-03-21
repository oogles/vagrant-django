#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/settings.sh

# Install Python dependencies from requirements.txt. If DEBUG is true, also
# install extra dev dependencies from dev_requirements.txt.
echo " "
echo " --- Install Python dependencies ---"
if [[ -f "$SRC_DIR/requirements.txt" ]]; then
    su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q -r $SRC_DIR/requirements.txt"
    echo "Done"
else
    echo "None found"
fi

if [[ "$DEBUG" -eq 1 ]]; then
    echo " "
    echo " --- Install Python additional dev dependencies ---"
    if [[ -f "$SRC_DIR/dev_requirements.txt" ]]; then
        su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q -r $SRC_DIR/dev_requirements.txt"
        echo "Done"
    else
        echo "None found"
    fi
fi

# Install node.js dependencies from package-lock.json, if necessary.
# Check for package-lock.json over package.json, and use "npm ci" over
# "npm install", to avoid the possibility of the provisioning process altering
# the package-lock.json file.
if [[ -f "$SRC_DIR/package-lock.json" ]]; then
    echo " "
    echo " --- Install node.js dependencies ---"
    if [[ "$DEBUG" -eq 1 ]]; then
        su - webmaster -c "cd $SRC_DIR && npm ci --quiet"
    else
        su - webmaster -c "cd $SRC_DIR && npm ci --production --quiet"
    fi
fi

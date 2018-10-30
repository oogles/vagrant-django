#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

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

# Install node.js dependencies from package.json, if necessary
if [[ -f "$SRC_DIR/package.json" ]]; then
    echo " "
    echo " --- Install node.js dependencies ---"
    if [[ "$DEBUG" -eq 1 ]]; then
        su - webmaster -c "cd $SRC_DIR && npm install --quiet"
    else
        su - webmaster -c "cd $SRC_DIR && npm install --production --quiet"
    fi
fi

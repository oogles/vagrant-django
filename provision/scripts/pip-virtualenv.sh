#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

echo " "
echo " --- Install/configure pip/virtualenv ---"

# Download get-pip.py if it doesn't already exist, install pip
if ! command -v pip  >/dev/null; then
    wget -q https://bootstrap.pypa.io/get-pip.py
    python get-pip.py
    rm get-pip.py
fi

# Install virtualenv
pip install -q virtualenv

# Create a virtualenv for the project
if [[ ! -d "$APP_DIR/virtualenv/" ]]; then
    echo " "
    echo "Creating virtualenv..."
    su - webmaster -c "virtualenv $APP_DIR/virtualenv"
fi

# Configure virtualenv to activate automatically when SSHing in
if ! grep -Fxq "$VENV_ACTIVATE_CMD" /home/webmaster/.profile ; then
cat <<EOF >> /home/webmaster/.profile

$VENV_ACTIVATE_CMD
cd $SRC_DIR
EOF
fi

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
    echo " ---  Install Python additional dev dependencies ---"
    if [[ -f "$SRC_DIR/dev_requirements.txt" ]]; then
        su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q -r $SRC_DIR/dev_requirements.txt"
        echo "Done"
    else
        echo "None found"
    fi
fi

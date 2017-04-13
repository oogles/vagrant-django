#!/usr/bin/env bash

echo " "
echo " --- Install/configure pip/virtualenv ---"

PROJECT_NAME="$1"
BUILD_MODE="$2"
DEBUG="$3"

# Download get-pip.py if it doesn't already exist, install pip
if ! command -v pip; then
    wget -q https://bootstrap.pypa.io/get-pip.py
	python get-pip.py
	rm get-pip.py
fi

# Install virtualenv
pip install -q virtualenv

# Create a virtualenv for the project
if [[ ! -d "/home/vagrant/proj/virtualenv/" ]]; then
    echo " "
    echo "Creating virtualenv..."
	su - vagrant -c "virtualenv ~/proj/virtualenv"
fi

ACTIVATE_STR="source ~/proj/virtualenv/bin/activate"

# Configure virtualenv to activate automatically when SSHing in
if ! grep -Fxq "$ACTIVATE_STR" .profile ; then
cat <<EOF >> .profile

$ACTIVATE_STR
cd /vagrant
EOF
fi

# Install Python dependencies from requirements.txt (if any) if this environment
# is being provisioned for a full project. If it is for a single app, it will
# not have a requirements.txt file, but install some common development aids.
if [[ "$BUILD_MODE" == "project" ]]; then
    echo " "
    echo " --- Install Python dependencies ---"
    if [ -f /vagrant/requirements.txt ]; then
        su - vagrant -c "$ACTIVATE_STR && pip install -q -r /vagrant/requirements.txt"
        echo "Done"
    else
        echo "None found"
    fi
fi

if [[ "$DEBUG" -eq 1 ]]; then
    echo " "
    echo " ---  Install Python dev dependencies ---"
    if [ -f /vagrant/dev_requirements.txt ]; then
        su - vagrant -c "$ACTIVATE_STR && pip install -q -r /vagrant/dev_requirements.txt"
        echo "Done"
    else
        echo "None found"
    fi
fi
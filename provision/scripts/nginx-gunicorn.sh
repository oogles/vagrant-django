#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

#
# NOTE: The various config files copied and/or linked to as part of provisioning
# nginx and gunicorn are deliberately copied out of the provision/conf directory.
# Symlinks and/or references *could* be made to the repository's own copy of
# these config files, but that allows a "git pull" to make server configuration
# changes. Referencing a copy means the provisioning scripts need to be re-run
# to enact such changes - a deliberate step with expected side-effects.
#

echo " "
echo " --- Install nginx ---"

echo "Installing..."
apt-get -qq install nginx

# Create additional directories
mkdir -p "$APP_DIR/conf/nginx/"
mkdir -p "$APP_DIR/logs/nginx/"

echo " "
echo "Copying nginx.conf..."

# Copy nginx.conf into $APP_DIR/conf, where it can be referenced by the
# supervisor program
cp "$PROVISION_DIR/conf/nginx/nginx.conf" "$APP_DIR/conf/nginx/"

echo " "
echo "Copying site config..."

# Copy the site config into sites-available
cp "$PROVISION_DIR/conf/nginx/site" "/etc/nginx/sites-available/$PROJECT_NAME"

# Link the copied site config into sites-enabled
if [[ ! -L "/etc/nginx/sites-enabled/$PROJECT_NAME" ]]; then
    ln -s "/etc/nginx/sites-available/$PROJECT_NAME" "/etc/nginx/sites-enabled/$PROJECT_NAME"
fi

# Remove the "default" site config from sites-enabled
if [[ -L "/etc/nginx/sites-enabled/default" ]]; then
    rm "/etc/nginx/sites-enabled/default"
fi

echo " "
echo "Stopping service (to be handled by supervisor)..."
service nginx stop

echo "Done"


echo " "
echo " --- Install gunicorn ---"

echo "Installing..."
su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q gunicorn"

# Create additional directories
mkdir -p "$APP_DIR/conf/gunicorn/"
mkdir -p "$APP_DIR/logs/gunicorn/"

echo " "
echo "Copying conf.py..."

# Copy conf.py into $APP_DIR/conf, where it can be referenced by the
# supervisor program
cp "$PROVISION_DIR/conf/gunicorn/conf.py" "$APP_DIR/conf/gunicorn/"

echo "Done"

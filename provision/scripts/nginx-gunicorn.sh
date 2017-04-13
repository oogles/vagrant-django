#!/usr/bin/env bash

PROJECT_NAME="$1"
VENV_ACTIVATE_STR="source ~/proj/virtualenv/bin/activate"

echo " "
echo " --- Install nginx ---"

echo "Installing..."
apt-get -qq install nginx

echo " "
echo "Linking site config..."

# Link the copied site config into sites-enabled
if [[ ! -L "/etc/nginx/sites-enabled/$PROJECT_NAME" ]]; then
    ln -s "/vagrant/provision/conf/nginx/site" "/etc/nginx/sites-enabled/$PROJECT_NAME"
fi

# Remove the "default" site config from sites-enabled
if [[ -L "/etc/nginx/sites-enabled/default" ]]; then
    rm "/etc/nginx/sites-enabled/default"
fi

echo " "
echo "Stopping service..."
service nginx stop

echo " "
echo "Adding supervisor program..."
cp "/vagrant/provision/conf/nginx/supervisor_program.conf" "/etc/supervisor/conf.d/nginx.conf"

echo "Done"


echo " "
echo " --- Install gunicorn ---"

echo "Installing..."
su - vagrant -c "$VENV_ACTIVATE_STR && pip install -q gunicorn"

echo " "
echo "Adding supervisor program..."
cp "/vagrant/provision/conf/gunicorn/supervisor_program.conf" "/etc/supervisor/conf.d/gunicorn.conf"

echo "Done"

#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

#
# NOTE: The various config files required as part of provisioning nginx and
# gunicorn are copied out of the /tmp/conf directory so a persistent reference
# to them can be maintained.
# The versions in provision/conf/ are not used as this would be complex with
# regard to multiple deployment support and would allows a "git pull" to make
# server configuration changes - such changes are better left to a deliberate
# re-provision step. which is expected to have such side effects.
#

echo " "
echo " --- Install nginx ---"

echo "Installing..."
apt-get -qq install nginx

# Create additional directories
mkdir -p "$APP_DIR/conf/nginx/"
mkdir -p "$APP_DIR/logs/nginx/"

# Copy nginx.conf into $APP_DIR/conf, where it can be referenced by the
# supervisor program. Also copy any snippets - they will be assumed to be
# relative to nginx.conf.
echo " "
echo "Copying nginx.conf..."
cp "/tmp/conf/nginx/nginx.conf" "$APP_DIR/conf/nginx/"

echo " "
echo "Copying snippets..."
snippet_dir="/tmp/conf/nginx/snippets"
if [[ ! -d "$snippet_dir" ]]; then
    echo "Nothing to copy"
else
    # Copy over changes and also delete obsolete files
    rsync -r --del "$snippet_dir/" "$APP_DIR/conf/nginx/snippets/"
fi

echo " "
echo "Copying site config..."

# Copy the site config into sites-available
cp "/tmp/conf/nginx/site" "/etc/nginx/sites-available/$PROJECT_NAME"

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


# Only install gunicorn in production environments
if [[ "$DEBUG" -eq 0 ]]; then
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
    cp "/tmp/conf/gunicorn/conf.py" "$APP_DIR/conf/gunicorn/"

    echo "Done"
fi

#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

#
# See https://linuxize.com/post/secure-nginx-with-let-s-encrypt-on-ubuntu-18-04/
#

echo " "
echo "=================================================="
echo " "

function error() {
    echo "--------------------------------------------------"
    echo "ERROR: $1"
    echo "--------------------------------------------------"
    echo " "
    echo "=================================================="
    exit 1
}

email="$1"
shift  # move past email address parameter
if [[ ! "$email" ]]; then
    error "No email address provided."
fi

if [[ ! "$@" ]]; then
    error "At least one domain name required."
fi

# Requires a separate "secure" site config
secure_config="/tmp/conf/nginx/secure-site"
if [[ ! -f "$secure_config" ]]; then
    error "No secure site config found."
fi

# Requires a supervisor program for nginx
nginx_program="/tmp/conf/supervisor/programs/nginx.conf"
if [[ ! -f "$nginx_program" ]]; then
    error "No supervisor program for nginx found."
fi

if [[ -L "/etc/nginx/sites-enabled/secure-$PROJECT_NAME" ]]; then
    error "It appears TLS is already configured."
fi

echo "CONFIGURE TLS"

# Only copy secure site config into sites-available initially
echo " "
echo " --- Copy secure site config ---"
cp "$secure_config" "/etc/nginx/sites-available/secure-$PROJECT_NAME"
echo "Done"

echo " "
echo " --- Install certbot ---"
apt-get -qq install certbot

echo " "
echo " --- Configure Let's Encrypt ---"
mkdir -p "$APP_DIR/letsencrypt/.well-known"
chgrp www-data "$APP_DIR/letsencrypt"
chmod g+s "$APP_DIR/letsencrypt"
echo "Done"

echo " "
echo " --- Obtain certificate ---"

# Temporarily reconfigure supervisor to just run nginx
echo " "
echo "Temporarily starting nginx via supervisor..."
mv /etc/supervisor/conf.d /etc/supervisor/~conf.d
mkdir /etc/supervisor/conf.d
cp "$nginx_program" /etc/supervisor/conf.d
supervisorctl reload

echo " "
echo "Running certbot..."
certbot certonly --agree-tos --email "$email" --webroot -w "$APP_DIR/letsencrypt/" "${@/#/-d }"

# Restore the original supervisor program configuration
echo " "
echo "Resetting supervisor..."
rm -rf /etc/supervisor/conf.d
mv /etc/supervisor/~conf.d /etc/supervisor/conf.d
supervisorctl reload

echo " "
echo " --- Configure auto-renewal ---"

# TODO

echo " "
echo " --- Enable secure site ---"

# Link the copied site config into sites-enabled, replacing the unsecured version
rm "/etc/nginx/sites-enabled/$PROJECT_NAME"
ln -s "/etc/nginx/sites-available/secure-$PROJECT_NAME" "/etc/nginx/sites-enabled/secure-$PROJECT_NAME"
echo "Done"

echo " "
echo "END"
echo " "
echo "=================================================="

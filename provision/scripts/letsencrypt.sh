#!/usr/bin/env bash

#
# See https://linuxize.com/post/secure-nginx-with-let-s-encrypt-on-ubuntu-18-04/
#

echo " "
echo "=================================================="
echo " "
echo "CONFIGURE TLS"

# Define and source common settings
/opt/app/src/provision/scripts/init.sh
if [[ $? != 0 ]]; then
    echo " "
    echo "=================================================="
    exit 1
fi

source /tmp/settings.sh

function error() {
    echo "--------------------------------------------------"
    echo "ERROR: $1"
    echo "--------------------------------------------------"
    echo " "
    echo "=================================================="
    exit 1
}

echo " "
echo " --- Verify config ---"

email="$1"
shift  # move past email address parameter
if [[ ! "$email" ]]; then
    error "No email address provided."
fi

if [[ ! "$@" ]]; then
    error "At least one domain name required."
fi

# Requires a separate "secure" site config in sites-available
secure_config="/etc/nginx/sites-available/secure-$PROJECT_NAME"
if [[ ! -f "$secure_config" ]]; then
    error "No secure site config found in sites-available."
fi

if [[ -L "/etc/nginx/sites-enabled/secure-$PROJECT_NAME" ]]; then
    error "It appears TLS is already configured."
fi

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
certbot certonly --agree-tos --email "$email" --webroot -w "$APP_DIR/letsencrypt/" "${@/#/-d }"

echo " "
echo " --- Enable secure site ---"

# Link the copied site config into sites-enabled, replacing the unsecured
# version. Use the same name for the link so that reprovisioning does not
# re-enable the unsecured version.
rm "/etc/nginx/sites-enabled/$PROJECT_NAME"
ln -s "/etc/nginx/sites-available/secure-$PROJECT_NAME" "/etc/nginx/sites-enabled/$PROJECT_NAME"
echo "Done"

# Clean up before finishing
"$PROVISION_DIR/scripts/cleanup.sh"

echo " "
echo "END"
echo " "
echo "=================================================="
echo " "
echo "NOTE: Certificates will be automatically renewed."
echo "You may want to test the certificate renewal process with:"
echo "sudo certbot renew --dry-run"
echo " "
echo "=================================================="

#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/settings.sh

echo " "
echo " --- Configure SSH ---"

echo "Adding SSH public key..."

KEY_FILE="/home/webmaster/.ssh/authorized_keys"

if [[ ! -f "$KEY_FILE" ]]; then
    su - webmaster -c "mkdir /home/webmaster/.ssh"
    chmod 700 /home/webmaster/.ssh
    su - webmaster -c "touch $KEY_FILE"
    chmod 600 "$KEY_FILE"
fi

if grep -Fxq "$PUBLIC_KEY" "$KEY_FILE" ; then
    echo "Already present"
else
    echo "$PUBLIC_KEY" >> "$KEY_FILE"
fi


echo " "
echo "Fixing www-data user..."

# Create a .ssh directory for the www-data user so they can use SSH.
# E.g. If executing remote git commands over SSH from within the provisioned
# environment.
# The /var/www/ directory itself may also need creating.
# This does not allow the www-data user to login to the provisioned environment
# using SSH.
if [[ ! -d /var/www/.ssh ]]; then
    mkdir -p /var/www/.ssh
    chown www-data:www-data /var/www/.ssh/
    echo "Done"
else
    echo "Already fixed"
fi


echo " "
echo "Hardening SSH..."

SSH_CONFIG="/etc/ssh/sshd_config"

if [[ "$DEBUG" -eq 1 ]]; then
    ALLOWED_USERS="webmaster vagrant"
else
    ALLOWED_USERS="webmaster"
fi

# Disable SSH as root
sed -i -r 's|#?PermitRootLogin .*|PermitRootLogin no|' "$SSH_CONFIG"

# Disable SSH using passwords
sed -i -r 's|#?PasswordAuthentication .*|PasswordAuthentication no|' "$SSH_CONFIG"

# Add a newline to the end of the SSH config file, if it doesn't already end
# with a newline. Prevents the following statements from adding new directives
# on the same line as another, and has no effect if the directives already exist.
sed -i -e '$a\' "$SSH_CONFIG"

# Restrict valid SSH users
if ! grep -q AllowUsers "$SSH_CONFIG" ; then
    echo "AllowUsers $ALLOWED_USERS" >> "$SSH_CONFIG"
else
    sed -i -r "s|#?AllowUsers .*|AllowUsers $ALLOWED_USERS|" "$SSH_CONFIG"
fi

# Disable DNS
if ! grep -q UseDNS "$SSH_CONFIG" ; then
    echo "UseDNS no" >> "$SSH_CONFIG"
else
    sed -i -r 's|#?UseDNS .*|UseDNS no|' "$SSH_CONFIG"
fi


echo " "
echo "Restarting SSH..."
service ssh restart

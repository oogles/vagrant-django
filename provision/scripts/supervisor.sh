#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

echo " "
echo " --- Install/configure supervisor ---"

echo "Installing..."
apt-get -qq install supervisor

# Ensure the supervisord service is stopped (it may or may not be started)
service supervisor stop

# Add a "supervisor" group and add the webmaster user to it.
# Updating the [unix_http_server] section of the supervisor configuration file
# to make the supervisor socket file writable by this group eliminates the
# need for the webmaster user to use sudo for supervisorctl commands.
#
# E.g.
# [unix_http_server]
# file=/var/run/supervisor.sock    ; (the path to the socket file)
# chmod=0770                       ; socket file mode (default 0700)
# chown=root:supervisor
#
# See https://bixly.com/blog/supervisord-or-how-i-learned-to-stop-worrying-and-um-use-supervisord/

echo " "
echo "Adding supervisor group..."
if ! grep -q -E "^supervisor:" /etc/group ; then
    groupadd supervisor
    usermod -a -G supervisor webmaster
fi

echo " "
echo "Copying config file..."
cp "$PROVISION_DIR/conf/supervisor/supervisord.conf" /etc/supervisor/supervisord.conf

echo " "
echo "Copying programs..."
if [[ "$DEBUG" -eq 1 ]]; then
    PROGRAM_DIR="$PROVISION_DIR/conf/supervisor/dev_programs"
else
    PROGRAM_DIR="$PROVISION_DIR/conf/supervisor/production_programs"
fi

if [[ ! -d "$PROGRAM_DIR" ]]; then
    echo "Nothing to copy"
else
    rsync -r "$PROGRAM_DIR/" /etc/supervisor/conf.d
fi

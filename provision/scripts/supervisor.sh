#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/settings.sh

echo " "
echo " --- Install/configure supervisor ---"

echo "Installing..."
apt-get -qq install supervisor

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
cp "/tmp/conf/supervisor/supervisord.conf" /etc/supervisor/supervisord.conf

echo " "
echo "Copying programs..."
program_dir="/tmp/conf/supervisor/programs"
if [[ ! -d "$program_dir" ]]; then
    echo "Nothing to copy"
else
    # Copy over changes and also delete obsolete files
    rsync -r --del "$program_dir/" /etc/supervisor/conf.d
fi

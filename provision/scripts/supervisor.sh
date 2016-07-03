#!/usr/bin/env bash

echo " "
echo " --- Install/configure supervisor ---"

echo "Installing..."
apt-get -qq install supervisor

# Add a "supervisor" group and add the vagrant user to it.
# Updating the [unix_http_server] section of the supervisor configuration file
# to make the supervisor socket file writable by this group eliminates the
# need for the vagrant user to use sudo for supervisorctl commands.
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
    usermod -a -G supervisor vagrant
fi

echo " "
echo "Copying config file..."
cp /vagrant/provision/conf/supervisord.conf /etc/supervisor/supervisord.conf

echo " "
echo "Restarting..."
supervisorctl reload

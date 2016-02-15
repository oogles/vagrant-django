#!/usr/bin/env bash

echo " "
echo " --- Copy user config files ---"

# If a conf/ directory exists, copy all contents to the vagrant user's home
# directory, without updating/replacing existing files.

su vagrant <<EOF
shopt -s dotglob nullglob
cp -n /vagrant/provision/conf/* ~/
shopt -u dotglob nullglob
EOF

echo "Done"

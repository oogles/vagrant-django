#!/usr/bin/env bash

echo " "
echo " --- ag ---"

apt-get -qq install silversearcher-ag

if [[ -f /vagrant/provision/config/.agignore ]]; then
	su - vagrant -c "cp /vagrant/provision/config/.agignore ~/.agignore"
fi

#!/usr/bin/env bash

# Get environment-specific variables from config.
# PUBLIC_KEY:      Optional. A custom public key to install in .ssh/authorized_keys.
if [ -f /vagrant/provision/config/env.sh ]; then
	source /vagrant/provision/config/env.sh
fi

echo " "
echo "=================================================="
echo " "
echo "START PROVISION"
echo " "

echo " --- Add/update apt repos ---"

#echo " "
#echo "Updating..."
apt-get update

# Install all the things
/vagrant/provision/git.sh

# Add public key to authorized_keys
if [ "$PUBLIC_KEY" ]; then
	if ! grep -Fxq "$PUBLIC_KEY" .ssh/authorized_keys ; then
		echo "$PUBLIC_KEY" >> .ssh/authorized_keys
	fi
else
	echo " "
	echo "--------------------------------------------------"
	echo "WARNING: No PUBLIC_KEY variable defined in provision/config/env.sh."
	echo "No custom public key installed."
	echo "--------------------------------------------------"
fi

echo " "
echo "END PROVISION"
echo " "
echo "=================================================="

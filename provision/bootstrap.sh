#!/usr/bin/env bash

# vagrant-django
# Vagrant provisioning for Django projects.
# https://github.com/oogles/vagrant-django
# v0.1

PROJECT_NAME="$1"
BUILD_MODE="$2"

if [[ ! "$PROJECT_NAME" ]]; then
	echo "--------------------------------------------------"
	echo "ERROR: No project name provided."
	echo "--------------------------------------------------"
	exit 1
fi

if [[ ! "$BUILD_MODE" ]]; then
    echo "--------------------------------------------------"
	echo "ERROR: No build mode provided."
	echo "--------------------------------------------------"
	exit 1
elif [[ "$BUILD_MODE" != "project" && "$BUILD_MODE" != "app" ]]; then
    echo "--------------------------------------------------"
	echo "ERROR: Unknown build mode \"$BUILD_MODE\"."
	echo "--------------------------------------------------"
	exit 1
fi

# Get environment-specific variables from config.
# For a full description of the available variables, and the effects they have
# on the provisioning process, see the docs at https://vagrant-django.readthedocs.org/.
# DB_PASS:         Required. The password to use for the app database created in 
#                  PostgreSQL.
# PUBLIC_KEY:      Optional. A custom public key to install in .ssh/authorized_keys.
# DEBUG:           Optional. Set to 1 to set 'DEBUG': True in the environment-specific
#                  settings file for the project.
# TIMEZONE:        Optional. The server timezone. Defaults to Australia/Sydney.
if [[ -f /vagrant/provision/config/env.sh ]]; then
	source /vagrant/provision/config/env.sh
else
	echo "--------------------------------------------------"
	echo "ERROR: Missing required environment-specific config file provision/config/env.sh."
	echo "--------------------------------------------------"
	exit 1
fi

if [[ ! "$DB_PASS" ]]; then
	echo "--------------------------------------------------"
	echo "ERROR: No DB_PASS variable defined in provision/config/env.sh."
	echo "--------------------------------------------------"
	exit 1
fi

if [[ "$DEBUG" && "$DEBUG" -eq 1 ]]; then
    DEBUG=1
else
    DEBUG=2
fi

echo " "
echo "=================================================="
echo " "
echo "START PROVISION FOR \"$PROJECT_NAME\""
echo " "

echo " --- Adding SSH public key ---"
if [[ "$PUBLIC_KEY" ]]; then
	if ! grep -Fxq "$PUBLIC_KEY" .ssh/authorized_keys ; then
		echo "$PUBLIC_KEY" >> .ssh/authorized_keys
    else
        echo "Public key already present in authorized_keys."
	fi
else
	echo "No PUBLIC_KEY env setting defined. Custom public key not added."
fi

echo " "
echo " --- Setting timezone ---"
if [[ ! "$TIMEZONE" ]]; then
	TIMEZONE='Australia/Sydney'
fi
echo "$TIMEZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

echo " "
echo " --- Add/update apt repos ---"

# Add custom apt repo for postgres
/vagrant/provision/postgres-repo.sh

echo " "
echo "Updating..."
apt-get update

# Install all the things
/vagrant/provision/git.sh
/vagrant/provision/pip-virtualenv.sh "$PROJECT_NAME" "$BUILD_MODE" "$DEBUG"
/vagrant/provision/postgres.sh "$PROJECT_NAME" "$DB_PASS"

if [[ "$BUILD_MODE" == "project" ]]; then
    /vagrant/provision/write-env-settings.sh "$PROJECT_NAME" "$DB_PASS" "$DEBUG"
fi

if [[ -f "/vagrant/manage.py" ]]; then
    echo " "
    echo " --- Run migrations ---"
    su - vagrant -c "source ~/.virtualenvs/$PROJECT_NAME/bin/activate && /vagrant/manage.py migrate"
    
    # Add custom scripts
    if [[ ! -d bin ]] ; then
        su - vagrant -c "mkdir ~/bin"
    fi
else
    echo " "
    echo "--------------------------------------------------"
    echo "WARNING: No manage.py file detected."
    echo "No migrations have been run."
    echo "--------------------------------------------------"
fi

/vagrant/provision/bin/shell+.sh
/vagrant/provision/bin/runserver+.sh

echo " "
echo "END PROVISION"
echo " "
echo "=================================================="

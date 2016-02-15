#!/usr/bin/env bash

# vagrant-django
# Vagrant provisioning for Django projects.
# https://github.com/oogles/vagrant-django
# v0.3

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
# TIME_ZONE:       Optional. The server time zone. Defaults to Australia/Sydney.
if [[ -f /vagrant/provision/env.sh ]]; then
    source /vagrant/provision/env.sh
else
    echo "--------------------------------------------------"
    echo "ERROR: Missing required environment-specific config file provision/env.sh."
    echo "--------------------------------------------------"
    exit 1
fi

if [[ ! "$DB_PASS" ]]; then
    echo "--------------------------------------------------"
    echo "ERROR: No DB_PASS variable defined in provision/env.sh."
    echo "--------------------------------------------------"
    exit 1
fi

if [[ "$BUILD_MODE" == "app" ]]; then
    DEBUG=1
elif [[ "$DEBUG" && "$DEBUG" -eq 1 ]]; then
    DEBUG=1
else
    DEBUG=0
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
        echo "Done"
    else
        echo "Public key already present in authorized_keys."
    fi
else
    echo "No PUBLIC_KEY env setting defined. Custom public key not added."
fi

echo " "
echo " --- Setting time zone ---"
if [[ ! "$TIME_ZONE" ]]; then
    TIME_ZONE='Australia/Sydney'
fi
echo "$TIME_ZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# Add/update apt repos
/vagrant/provision/scripts/apt.sh

# Some basic installs
/vagrant/provision/scripts/install.sh

# Install and configure database
/vagrant/provision/scripts/database.sh "$PROJECT_NAME" "$DB_PASS"

# If a project-specific provisioning file is present, run it
if [[ -f /vagrant/provision/project.sh ]]; then
    echo " "
    echo " --- Running project-specific configuration ---"
	/vagrant/provision/project.sh "$PROJECT_NAME" "$BUILD_MODE" "$DEBUG"
fi

# Install and configure virtualenv and install python dependencies.
# Must run after postgres is installed if installing psycopg2, and after image
# libraries if installing Pillow.
/vagrant/provision/scripts/pip-virtualenv.sh "$PROJECT_NAME" "$BUILD_MODE" "$DEBUG"

# Install and configure nodejs/npm and install node dependencies, if the project
# makes use of them
if [[ -f /vagrant/package.json ]]; then
    /vagrant/provision/scripts/node-npm.sh "$DEBUG"
fi

# Copy necessary config files
if [[ -d /vagrant/provision/conf ]]; then
    /vagrant/provision/scripts/copy-conf.sh
fi

# Write environment settings file
if [[ "$BUILD_MODE" == "project" ]]; then
    /vagrant/provision/scripts/write-env-settings.sh "$PROJECT_NAME" "$DEBUG" "$DB_PASS" "$TIME_ZONE"
fi

echo " "
echo " --- Running migrations ---"
if [[ -f "/vagrant/manage.py" ]]; then
    su - vagrant -c "source ~/.virtualenvs/$PROJECT_NAME/bin/activate && /vagrant/manage.py migrate"
else
    echo "--------------------------------------------------"
    echo "WARNING: No manage.py file detected."
    echo "No migrations have been run."
    echo "--------------------------------------------------"
fi

# Add custom scripts
if [[ ! -d bin ]] ; then
    su - vagrant -c "mkdir ~/bin"
fi

/vagrant/provision/scripts/bin/shell+.sh
/vagrant/provision/scripts/bin/runserver+.sh

echo " "
echo "END PROVISION"
echo " "
echo "=================================================="

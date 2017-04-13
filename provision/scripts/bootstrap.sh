#!/usr/bin/env bash

# vagrant-django
# Vagrant provisioning for Django projects.
# https://github.com/oogles/vagrant-django
# v0.4.0a

# Ensure all provisioning scripts are executable
chmod 774 -R /opt/app/src/provision/scripts/

# Define a function for executing provisioning scripts. The first argument
# should be the path to the script file to execute. Remaining arguments will be
# passed through to the script. The primary reason for encapsulating these calls
# in a function is to exit this outer script if one of the executed scripts
# returns a non-zero exit code.
function run_script() {
    eval "$1" "${@:2}"
    if [[ $? != 0 ]]; then
        echo " "
        echo "=================================================="
        exit 1
    fi
}

# Define common settings, passing the arguments that were passed to this script
run_script /opt/app/src/provision/scripts/settings.sh "$1" "$2"

# Source the defined settings
source /tmp/vagrant_provision_settings.sh
source /tmp/vagrant_provision_bootstrap_settings.sh

echo " "
echo "=================================================="
echo " "
echo "START PROVISION FOR \"$PROJECT_NAME\""
echo " "

# Setup the "webmaster" user and home directory
run_script "$PROVISION_DIR/scripts/user.sh"

# Configure SSH
run_script "$PROVISION_DIR/scripts/ssh.sh" "$PUBLIC_KEY"

echo " "
echo " --- Set time zone ---"
if [[ ! "$TIME_ZONE" ]]; then
    TIME_ZONE='Australia/Sydney'
fi
echo "$TIME_ZONE" | tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# Set up app directory
run_script "$PROVISION_DIR/scripts/app-dir.sh"

## Add/update apt repos
#/vagrant/provision/scripts/apt.sh
#
## Enable a firewall in production environments
#if [[ "$DEBUG" -eq 0 ]]; then
#    /vagrant/provision/scripts/firewall.sh
#fi
#
## Some basic installs
#/vagrant/provision/scripts/install.sh
#
## Install and configure supervisor
#/vagrant/provision/scripts/supervisor.sh
#
## Install and configure database
#/vagrant/provision/scripts/database.sh "$PROJECT_NAME" "$DB_PASS"
#
## If a project-specific provisioning file is present, run it
#if [[ -f /vagrant/provision/project.sh ]]; then
#    echo " "
#    echo " --- Run project-specific configuration ---"
#	/vagrant/provision/project.sh "$PROJECT_NAME" "$BUILD_MODE" "$DEBUG"
#fi
#
## Install and configure virtualenv and install python dependencies.
## Must run after postgres is installed if installing psycopg2, and after image
## libraries if installing Pillow.
#/vagrant/provision/scripts/pip-virtualenv.sh "$PROJECT_NAME" "$BUILD_MODE" "$DEBUG"
#
## Install nginx and gunicorn for production environments
#if [[ "$DEBUG" -eq 0 ]]; then
#    /vagrant/provision/scripts/nginx-gunicorn.sh "$PROJECT_NAME"
#fi
#
## Install and configure nodejs/npm and install node dependencies, if the project
## makes use of them
#if [[ -f /vagrant/package.json ]]; then
#    /vagrant/provision/scripts/node-npm.sh "$DEBUG"
#fi
#
## Update supervisor to be aware of any programs configs added/updated as
## part of the above provisioning
#echo " "
#echo " --- Update supervisor ---"
#supervisorctl reread
#supervisorctl update
#
## Write environment settings file
#if [[ "$BUILD_MODE" == "project" ]]; then
#    /vagrant/provision/scripts/write-env-settings.sh "$PROJECT_NAME" "$DEBUG" "$DB_PASS" "$TIME_ZONE"
#fi
#
#echo " "
#echo " --- Run migrations ---"
#if [[ -f "/vagrant/manage.py" ]]; then
#    su - vagrant -c "source ~/proj/virtualenv/bin/activate && /vagrant/manage.py migrate"
#else
#    echo "--------------------------------------------------"
#    echo "WARNING: No manage.py file detected."
#    echo "No migrations have been run."
#    echo "--------------------------------------------------"
#fi

echo " "
echo "END PROVISION"
echo " "
echo "=================================================="

if [[ "$DEBUG" -eq 0 ]]; then
    echo " "
    echo "IMPORTANT"
    echo "The \"webmaster\" user account requires a password for sudo access."
    echo "NOTE: It does NOT require one for SSH access (password-based SSH access is disabled)."
    echo "Set a password using the following command:"
    echo "passwd"
    echo " "
    echo "=================================================="
fi

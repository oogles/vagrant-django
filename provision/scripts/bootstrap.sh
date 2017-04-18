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

# Add/update apt repos - get software current before doing anything
run_script "$PROVISION_DIR/scripts/apt.sh"

# Setup the "webmaster" user and home directory
run_script "$PROVISION_DIR/scripts/user.sh"

# Configure SSH
run_script "$PROVISION_DIR/scripts/ssh.sh" "$PUBLIC_KEY"

echo " "
echo " --- Set time zone ---"
if [[ ! "$TIME_ZONE" ]]; then
    TIME_ZONE='Australia/Sydney'
fi
echo "$TIME_ZONE" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

# Set up app directory
run_script "$PROVISION_DIR/scripts/app-dir.sh"

# Enable a firewall in production environments
if [[ "$DEBUG" -eq 0 ]]; then
    run_script "$PROVISION_DIR/scripts/firewall.sh"
fi

# Some basic installs
run_script "$PROVISION_DIR/scripts/install.sh"

# Install and configure supervisor
#run_script "$PROVISION_DIR/scripts/supervisor.sh"

# Install and configure database
run_script "$PROVISION_DIR/scripts/database.sh" "$DB_PASS"

# If a project-specific provisioning file is present, ensure it is executable
# and run it
if [[ -f "$PROVISION_DIR/project.sh" ]]; then
    echo " "
    echo " --- Run project-specific configuration ---"
    chmod 774 "$PROVISION_DIR/project.sh"
    run_script "$PROVISION_DIR/project.sh"
fi

# Install and configure virtualenv and install python dependencies.
# Must run after postgres is installed if installing psycopg2, and after image
# libraries if installing Pillow.
run_script "$PROVISION_DIR/scripts/pip-virtualenv.sh"

# Install nginx and gunicorn for production environments
if [[ "$DEBUG" -eq 0 ]]; then
    run_script "$PROVISION_DIR/scripts/nginx-gunicorn.sh"
fi

# Install and configure nodejs/npm and install node dependencies, if the project
# makes use of them
if [[ -f "$SRC_DIR/package.json" ]]; then
    run_script "$PROVISION_DIR/scripts/node-npm.sh"
fi

# Update supervisor to be aware of any programs configs added/updated as
# part of the above provisioning
#echo " "
#echo " --- Update supervisor ---"
#supervisorctl reread
#supervisorctl update

# Write environment settings file
if [[ "$BUILD_MODE" == "project" ]]; then
    run_script "$PROVISION_DIR/scripts/write-env-settings.sh" "$DB_PASS" "$TIME_ZONE"
fi

echo " "
echo " --- Run migrations ---"
if [[ -f "$SRC_DIR/manage.py" ]]; then
    su - webmaster -c "$VENV_ACTIVATE_CMD && $SRC_DIR/manage.py migrate"
else
    echo "--------------------------------------------------"
    echo "WARNING: No manage.py file detected."
    echo "No migrations have been run."
    echo "--------------------------------------------------"
fi

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

#!/usr/bin/env bash

# vagrant-django
# Vagrant provisioning for Django projects.
# https://github.com/oogles/vagrant-django
# v0.7.0a

# Ensure all provisioning scripts are executable
chmod 774 -R /opt/app/src/provision/scripts/

# Define a function for executing provisioning scripts. The first argument
# should be the path to the script file to execute. Remaining arguments will be
# passed through to the script. The primary reason for encapsulating these calls
# in a function is to exit this outer script if one of the executed scripts
# returns a non-zero exit code.
function run_script() {
    "$1" "${@:2}"
    if [[ $? != 0 ]]; then
        echo " "
        echo "PROVISION ABORTED"
        echo " "
        echo "=================================================="
        exit 1
    fi
}

echo " "
echo "=================================================="
echo " "
echo "START PROVISION"

# Define common settings, passing the arguments that were passed to this script
run_script /opt/app/src/provision/scripts/settings.sh "$1"

# Source the defined settings
source /tmp/env.sh

# Get package lists current before doing anything
echo " "
echo " --- Update package lists ---"
apt-get -qq update
echo "Done"

# Setup the "webmaster" user and home directory
run_script "$PROVISION_DIR/scripts/user.sh"

# Configure SSH
run_script "$PROVISION_DIR/scripts/ssh.sh"

echo " "
echo " --- Set time zone ---"
timedatectl set-timezone "$TIME_ZONE"
timedatectl

# Set up app directory
run_script "$PROVISION_DIR/scripts/app-dir.sh"

# Write environment settings file
run_script "$PROVISION_DIR/scripts/write-env-settings.sh" "$SECRET_KEY" "$TIME_ZONE" "$DB_PASS"

# Enable a firewall in production environments
if [[ "$DEBUG" -eq 0 ]]; then
    run_script "$PROVISION_DIR/scripts/firewall.sh"
fi

# Some basic installs
run_script "$PROVISION_DIR/scripts/install.sh"

# Install and configure supervisor
run_script "$PROVISION_DIR/scripts/supervisor.sh"

# Install and configure database
run_script "$PROVISION_DIR/scripts/postgres.sh"

# Install and configure python and create a virtualenv.
# Must run after postgres is installed if installing psycopg2, and after image
# libraries if installing Pillow.
# Run before project-specific provisioning in case it needs to use python.
run_script "$PROVISION_DIR/scripts/python.sh"

# Install and configure nodejs/npm, if the project makes use of them.
# Run before project-specific provisioning in case it needs to use them.
if [[ -f "$SRC_DIR/package.json" ]]; then
    run_script "$PROVISION_DIR/scripts/node-npm.sh"
fi

# If a project-specific provisioning file is present, ensure it is executable
# and run it
if [[ -f "$PROVISION_DIR/project.sh" ]]; then
    echo " "
    echo " --- Run project-specific configuration ---"
    chmod 774 "$PROVISION_DIR/project.sh"
    run_script "$PROVISION_DIR/project.sh"
fi

# Install project dependencies (python and npm)
run_script "$PROVISION_DIR/scripts/dependencies.sh"

# Install nginx and gunicorn. Must run after virtualenv is installed.
run_script "$PROVISION_DIR/scripts/nginx-gunicorn.sh"

# Start supervisor now that program files are in place and any necessary
# installations/configurations for those programs are complete
echo " "
echo " --- Start/restart supervisor and all programs ---"
supervisorctl reload
echo "Done"

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

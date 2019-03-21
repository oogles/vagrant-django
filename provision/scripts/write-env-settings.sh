#!/usr/bin/env bash

# Create settings file for environment-specific settings, with some known
# values and useful defaults

# Source global provisioning settings
source /tmp/settings.sh

echo " "
echo " --- Write env.py file ---"

# Check that there is a project subdirectory to write the file into (this will
# put it in the same directory as settings.py for a standard Django project
# layout).
project_subdir="$SRC_DIR/$PROJECT_NAME"
if [[ ! -d "$project_subdir" ]]; then
    echo "--------------------------------------------------"
    echo "No env.py file written: No $project_subdir directory to write to."
    echo "--------------------------------------------------"
    exit 0;
fi

# Check that the file does not already exist
env_file="$project_subdir/env.py"
if [[ -f "$env_file" ]]; then
    echo "File already exists."
    exit 0;
fi

# Get additional variables
if [[ "$DEBUG" -eq 1 ]]; then
    DEBUG='True'
else
    DEBUG='False'
fi

# Replace the variable placeholders, and copy the env.py file
sed -i -e "s|{{debug}}|$DEBUG|g" \
       -e "s|{{secret_key}}|$SECRET_KEY|g" \
       -e "s|{{time_zone}}|$TIME_ZONE|g" \
       -e "s|{{project_name}}|$PROJECT_NAME|g" \
       -e "s|{{db_password}}|$DB_PASS|g" \
       /tmp/conf/env.py

cp /tmp/conf/env.py "$env_file"

# Explicitly set owner and group to www-data. This is required when writing to
# a location outside of the vagrant-managed synced folder (e.g. a production
# environment).
chown www-data:www-data "$env_file"

# Lock down the file permissions.
# Won't have an effect on a Windows host, but will in a proper Linux production
# environment.
chmod 640 "$env_file"

echo "File written to $env_file."

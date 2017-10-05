#!/usr/bin/env bash

# Create settings file for environment-specific settings, with some known
# values and useful defaults

# Source global provisioning settings
source /tmp/env.sh

echo " "
echo " --- Write env.py file ---"

# Check that there is a project subdirectory to write the file into (this will
# put it in the same directory as settings.py for a standard Django project
# layout).
PROJECT_SUBDIR="$SRC_DIR/$PROJECT_NAME"
if [[ ! -d "$PROJECT_SUBDIR" ]]; then
    echo "--------------------------------------------------"
    echo "No env.py file written: No $PROJECT_SUBDIR directory to write to."
    echo "--------------------------------------------------"
    exit 0;
fi

# Check that the file does not already exist
ENV_FILE="$PROJECT_SUBDIR/env.py"
if [[ -f "$ENV_FILE" ]]; then
    echo "File already exists."
    exit 0;
fi

# Get additional variables
if [[ "$DEBUG" -eq 1 ]]; then
    DEBUG='True'
else
    DEBUG='False'
fi

SECRET_KEY="$1"
TIME_ZONE="$2"
DB_PASSWORD="$3"

# Get the env.py template, replace the variable placeholders, and write the file
template=$(< "$PROVISION_DIR/templates/$ENV_PY_TEMPLATE")
echo "$template" \
  | sed -r -e "s|\\\$DEBUG|$DEBUG|g" \
           -e "s|\\\$SECRET_KEY|$SECRET_KEY|g" \
           -e "s|\\\$TIME_ZONE|$TIME_ZONE|g" \
           -e "s|\\\$PROJECT_NAME|$PROJECT_NAME|g" \
           -e "s|\\\$DB_PASSWORD|$DB_PASSWORD|g" \
  > $ENV_FILE

# Explicitly set owner and group to www-data. This is required when writing to
# a location outside of the vagrant-managed synced folder (e.g. a production
# environment).
chown www-data:www-data "$ENV_FILE"

# Lock down the file permissions.
# Won't have an effect on a Windows host, but will in a proper Linux production
# environment.
chmod 640 "$ENV_FILE"

echo "File written to $ENV_FILE."

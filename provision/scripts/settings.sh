#!/usr/bin/env bash
# Define two temporary settings files: one containing common variables to be
# sourced by all provisioning scripts, and the other to contain some additional
# variables only required by the bootstrap script.

echo " "
echo " --- Establishing settings ---"

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

# Define common paths used throughout the provisioning process
APP_DIR="/opt/app"
SRC_DIR="$APP_DIR/src"
PROVISION_DIR="$SRC_DIR/provision"

# Get environment-specific variables from config.
# For a full description of the available variables, and the effects they have
# on the provisioning process, see the docs at https://vagrant-django.readthedocs.org/.
# DB_PASS:         Required. The password to use for the app database created in
#                  PostgreSQL.
# PUBLIC_KEY:      Optional. A custom public key to install in .ssh/authorized_keys.
# DEBUG:           Optional. Set to 1 to set 'DEBUG': True in the environment-specific
#                  settings file for the project.
# TIME_ZONE:       Optional. The server time zone. Defaults to Australia/Sydney.
if [[ -f "$PROVISION_DIR/env.sh" ]]; then
    source "$PROVISION_DIR/env.sh"
else
    echo "--------------------------------------------------"
    echo "ERROR: Missing required environment-specific config file provision/env.sh."
    echo "--------------------------------------------------"
    exit 1
fi

# A public key is required
if [[ ! "$PUBLIC_KEY" ]]; then
    echo "--------------------------------------------------"
    echo "ERROR: No PUBLIC_KEY variable defined in provision/env.sh."
    echo "--------------------------------------------------"
    exit 1
fi

# Generate a database password if one is not given
if [[ ! "$DB_PASS" ]]; then
    echo " "
    echo "Generating database password..."
    DB_PASS=$("$PROVISION_DIR/scripts/utils/rand_str.sh" 20)

    # Write the generated value back to env.sh so the same value will be read
    # in if the VM is re-provisioned
    "$PROVISION_DIR/scripts/utils/write_var.sh" DB_PASS "$DB_PASS" /opt/app/src/provision/env.sh
fi

# Generate a secret key if one is not given
if [[ ! "$SECRET_KEY" ]]; then
    echo " "
    echo "Generating Django secret key..."
    SECRET_KEY=$("$PROVISION_DIR/scripts/utils/rand_str.sh" 128)

    # Write the generated value back to env.sh so the same value will be read
    # in if the VM is re-provisioned
    "$PROVISION_DIR/scripts/utils/write_var.sh" SECRET_KEY "$SECRET_KEY" /opt/app/src/provision/env.sh
fi

# Normalise the DEBUG flag
if [[ "$BUILD_MODE" == "app" ]]; then
    DEBUG=1
elif [[ "$DEBUG" && "$DEBUG" -eq 1 ]]; then
    DEBUG=1
else
    DEBUG=0
fi

# Define virtualenv activation command, for when the virtualenv gets created
VENV_ACTIVATE_CMD="source $APP_DIR/virtualenv/bin/activate"


echo " "
echo "Saving settings..."

# Write the temporary shell script files to contain the settings that can then
# be sourced by other provisioning scripts
cat <<EOF > /tmp/vagrant_provision_settings.sh
PROJECT_NAME="$PROJECT_NAME"
BUILD_MODE="$BUILD_MODE"
DEBUG="$DEBUG"
APP_DIR="$APP_DIR"
SRC_DIR="$SRC_DIR"
PROVISION_DIR="$PROVISION_DIR"
VENV_ACTIVATE_CMD="$VENV_ACTIVATE_CMD"
SECRET_KEY="$SECRET_KEY"
EOF

cat <<EOF > /tmp/vagrant_provision_bootstrap_settings.sh
DB_PASS="\"$DB_PASS\""  # wrap in quotes to make spaces safe
PUBLIC_KEY="\"$PUBLIC_KEY\""  # wrap in quotes to make spaces safe
TIME_ZONE="$TIME_ZONE"
EOF

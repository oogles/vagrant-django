#!/usr/bin/env bash
# Define two temporary settings files: one containing common variables to be
# sourced by all provisioning scripts, and the other to contain some additional
# variables only required by the bootstrap script.

echo " "
echo " --- Establishing settings ---"

PROJECT_NAME="$1"
BASE_PYTHON_VERSION="$2"

if [[ ! "$PROJECT_NAME" ]]; then
    echo "--------------------------------------------------"
    echo "ERROR: No project name provided."
    echo "--------------------------------------------------"
    exit 1
fi

# Define common paths used throughout the provisioning process
APP_DIR="/opt/app"
SRC_DIR="$APP_DIR/src"
PROVISION_DIR="$SRC_DIR/provision"

# Get environment-specific variables from config.
# For a full description of the available variables, and the effects they have
# on the provisioning process, see the docs at https://vagrant-django.readthedocs.io/.
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

# Normalise the DEBUG flag
if [[ "$DEBUG" && "$DEBUG" -eq 1 ]]; then
    DEBUG=1
else
    DEBUG=0
fi

# Generate a secret key if one is not given
if [[ ! "$SECRET_KEY" ]]; then
    echo " "
    echo "Generating Django secret key..."
    SECRET_KEY=$("$PROVISION_DIR/scripts/utils/rand_str.sh" 128)

    if [[ $? != 0 ]]; then
        echo "Could not generate secret key" >&2
        exit 1
    fi
fi

# Generate a database password if one is not given
if [[ ! "$DB_PASS" ]]; then
    echo " "
    echo "Generating database password..."
    DB_PASS=$("$PROVISION_DIR/scripts/utils/rand_str.sh" 20)

    if [[ $? != 0 ]]; then
        echo "Could not generate database password" >&2
        exit 1
    fi
fi

# Use default env.py template if one is not given
if [[ ! "$ENV_PY_TEMPLATE" ]]; then
    ENV_PY_TEMPLATE='env.py.txt'
fi


echo " "
echo "Storing settings..."

#
# Write all necessary settings back to env.sh, storing their
# defaulted/generated/normalised values. They will be read from there by most
# other provisioning scripts. In the case of generated values, this also ensures
# the same values get used if re-provisioning the same environment.
#

# Customisable settings
"$PROVISION_DIR/scripts/utils/write_var.sh" 'DEBUG' "$DEBUG" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'SECRET_KEY' "$SECRET_KEY" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'DB_PASS' "$DB_PASS" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'ENV_PY_TEMPLATE' "$ENV_PY_TEMPLATE" "$PROVISION_DIR/env.sh"

# Convenience settings for provisioning scripts
"$PROVISION_DIR/scripts/utils/write_var.sh" 'PROJECT_NAME' "$PROJECT_NAME" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'BASE_PYTHON_VERSION' "$BASE_PYTHON_VERSION" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'APP_DIR' "$APP_DIR" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'SRC_DIR' "$SRC_DIR" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'PROVISION_DIR' "$PROVISION_DIR" "$PROVISION_DIR/env.sh"

# Create symlink to env.sh for easy reference by provisioning scripts
ln -sf "$PROVISION_DIR/env.sh" /tmp/env.sh

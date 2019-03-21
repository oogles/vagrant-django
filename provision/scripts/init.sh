#!/usr/bin/env bash
# Read the relevant settings files, validate them, and store them in a temporary
# file for easy reference to the validated settings throughout the provisioning
# process. Also copy all relevant config files to a temporary location to act
# as the definitive source for the deployment-specific files throughout the
# provisioning process.

echo " "
echo " --- Establish settings ---"

# Define common paths used throughout the provisioning process
APP_DIR="/opt/app"
SRC_DIR="$APP_DIR/src"
PROVISION_DIR="$SRC_DIR/provision"

# Get project-specific variables from config.
# For a full description of the available variables, and the effects they have
# on the provisioning process, see the docs at https://vagrant-django.readthedocs.io/.
if [[ -f "$PROVISION_DIR/settings.sh" ]]; then
    source "$PROVISION_DIR/settings.sh"
else
    echo "--------------------------------------------------"
    echo "ERROR: Missing required project config file provision/settings.sh."
    echo "--------------------------------------------------"
    exit 1
fi

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

# A project name is required
if [[ ! "$PROJECT_NAME" ]]; then
    echo "--------------------------------------------------"
    echo "ERROR: No project name provided in provision/settings.sh."
    echo "--------------------------------------------------"
    exit 1
fi

# A DEBUG flag is required
if [[ ! "$DEBUG" ]]; then
    echo "--------------------------------------------------"
    echo "ERROR: No DEBUG variable defined in provision/env.sh."
    echo "--------------------------------------------------"
    exit 1
fi

# Normalise the DEBUG flag
if [[ "$DEBUG" == '1' ]]; then
    DEBUG=1
elif [[ "$DEBUG" == '0' ]]; then
    DEBUG=0
else
    echo "--------------------------------------------------"
    echo "ERROR: Invalid DEBUG value '$DEBUG'."
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

# Normalise the DEPLOYMENT setting
if [[ ! "$DEPLOYMENT" ]]; then
    DEPLOYMENT=''
fi

# Apply a default TIMEZONE, if necessary
if [[ ! "$TIME_ZONE" ]]; then
    TIME_ZONE='Australia/Sydney'
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


echo " "
echo "Storing settings..."

#
# Write all necessary settings back to env.sh, storing their
# defaulted/generated/normalised values. In the case of generated values, this
# ensures the same values get used if re-provisioning the same environment.
#

# Customisable settings
"$PROVISION_DIR/scripts/utils/write_var.sh" 'DEBUG' "$DEBUG" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'DEPLOYMENT' "$DEPLOYMENT" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'SECRET_KEY' "$SECRET_KEY" "$PROVISION_DIR/env.sh"
"$PROVISION_DIR/scripts/utils/write_var.sh" 'DB_PASS' "$DB_PASS" "$PROVISION_DIR/env.sh"

#
# Write ALL settings out to a temporary file for easy reference throughout the
# remainder of the provisioning process
#

# Start with both base settings files
cat "$PROVISION_DIR/settings.sh" "$PROVISION_DIR/env.sh" > /tmp/settings.sh

# Add shortcut variables only required during the provisioning process itself
"$PROVISION_DIR/scripts/utils/write_var.sh" 'APP_DIR' "$APP_DIR" /tmp/settings.sh
"$PROVISION_DIR/scripts/utils/write_var.sh" 'SRC_DIR' "$SRC_DIR" /tmp/settings.sh
"$PROVISION_DIR/scripts/utils/write_var.sh" 'PROVISION_DIR' "$PROVISION_DIR" /tmp/settings.sh

#
# Create a definitive source of config files for the the provisioning scripts
# to access, taking into consideration deployment-specific overrides
#

echo " "
echo "Copying config files..."

# Copy all contents of conf/ to a temporary directory. Use rsync to avoid
# needing to use "shopt -s dotglib" to enable cp to pick up dotfiles.
rsync -r --del "$PROVISION_DIR/conf/" /tmp/conf/

# Update with the relevant files specific to the configured deployment. Use
# rsync again to intelligently update only the files that differ.
if [[ "$DEPLOYMENT" != '' ]]; then
    deployment_conf_dir="$PROVISION_DIR/conf-$DEPLOYMENT/"
    if [[ -d "$deployment_conf_dir" ]]; then
        echo " "
        echo "Adding $DEPLOYMENT overrides..."
        rsync -r "$deployment_conf_dir" /tmp/conf/
    fi
fi

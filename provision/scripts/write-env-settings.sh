#!/usr/bin/env bash

# Create settings file for environment-specific settings, with some known
# values and useful defaults

# Source global provisioning settings
source /tmp/vagrant_provision_settings.sh

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
DB_PASS="$3"

cat <<EOF > "$ENV_FILE"
# Format these environment-specific settings as a dictionary, in order to:
# - mimic the use of environment variables in other settings files
#   os.environ.get() vs env.environ.get()
# - enable the use of defaults
#   env.environ.get('LEVEL_OF_AWESOME', 0)
# - enable the use of Python types (int, bool, etc)
# - provide those with little knowledge of the vagrant provisioning process, or
#   environment variables in general, a single point of reference for all
#   environment-specific settings and a visible source for those magically
#   obtained settings values.
#
# While this is Python, the convention should be to use simple name/value pairs
# in the dictionary below, without the use of code statements (conditionals,
# loops, etc). Such statements should be left to the other settings files,
# though they could be based on some setting/s below.
# The idea is to provide an easy reference to, and use of, environment-specific
# settings, without violating 12factor (http://12factor.net/) too heavily (by
# having code that is not committed to source control)

environ = {
    'DEBUG': $DEBUG,
    'SECRET_KEY': r'$SECRET_KEY',
    'TIME_ZONE': '$TIME_ZONE',
    'DB_USER': '$PROJECT_NAME',
    'DB_PASSWORD': r'$DB_PASS'
}
EOF

# Explicitly set owner and group to www-data. This is required when writing to
# a location outside of the vagrant-managed synced folder (e.g. a production
# environment).
chown www-data:www-data "$ENV_FILE"

# Make the file only accessible to the owner.
# Won't work in VirtualBox shared folders, but will in a proper Linux production
# environment.
chmod 440 "$ENV_FILE"

echo "File written to $ENV_FILE."

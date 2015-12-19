#!/usr/bin/env bash

# Create settings file for environment-specific settings, with some known
# values and useful defaults

echo " "
echo " --- Write env.py file ---"

PROJECT_NAME="$1"

# Check that there is a project subdirectory to write the file into (this will
# put it in the same directory as settings.py for a standard Django project
# layout).
PROJECT_SUBDIR="/vagrant/$PROJECT_NAME"
if [[ ! -d "$PROJECT_SUBDIR" ]]; then
    echo "--------------------------------------------------"
    echo "WARNING: No $PROJECT_SUBDIR directory to write env.py to."
    echo "No env.py file written."
    echo "--------------------------------------------------"
    exit 0;
fi

# Check that the file does not alredy exist
ENV_FILE="$PROJECT_SUBDIR/env.py"
if [[ -f "$ENV_FILE" ]]; then
    echo "File already exists."
    exit 0;
fi

# Get additional variables
if [[ "$2" -eq 1 ]]; then
	DEBUG='True'
else
	DEBUG='False'
fi

DB_PASS="$3"
TIME_ZONE="$4"

# Generate SECRET_KEY using a Python script to choose 100 random characters from
# a set of letters, numbers and punctuation. Note: an explicit list of punctuation
# is provided, rather than using string.punctuation, so as to exclude single quotes,
# double quotes and backticks. This is done to avoid SyntaxErrors, both in this script and in
# the env.py file when it is written.
SECRET_KEY=`python -c 'import random; import string; print "".join([random.SystemRandom().choice(string.letters + string.digits + "!#$%&\()*+,-./:;<=>?@[\\]^_{|}~") for i in range(128)])'`

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
    'SECRET_KEY': '$SECRET_KEY',
    'DB_USER': '$PROJECT_NAME',
    'DB_PASSWORD': '$DB_PASS',
    'TIME_ZONE': '$TIME_ZONE'
}
EOF

# Make the file only accessible to the owner.
# Won't work in VirtualBox shared folders, but will in a proper Linux production
# environment.
chmod 600 "$ENV_FILE"

echo "File written to $ENV_FILE."

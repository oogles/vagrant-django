#!/usr/bin/env bash
# Environment-specific settings used by the provisioning process

#
# Required
#

PUBLIC_KEY=''

#
# Optional
#

DEBUG=1
TIME_ZONE='Australia/Sydney'

# List of python versions to install (e.g. to use non-system version for
# virtualenv or to test with multiple versions via tox).
# Define explicit versions: PYTHON_VERSIONS=('2.7.14' '3.5.4' '3.6.4')
PYTHON_VERSIONS=()

# A secret key will be generated automatically if not provided.
#SECRET_KEY=''

# A database password will be generated automatically if not provided.
#DB_PASS=''

# The template file for the env.py file written during provisioning, relative
# to provision/templates/.
# Defaults env.py.txt
#ENV_PY_TEMPLATE=''

#
# Non-customisable settings will be created below here by
# the provisioning process
#

#!/usr/bin/env bash
# Environment-specific settings used by the provisioning process.
# See: https://vagrant-django.readthedocs.io/en/latest/config.html#env-sh

DEBUG='1'
PUBLIC_KEY=''

# Associative array of template values to replace in nginx config files. The
# default site configs (for production) use the "{{domain}}" variable. Custom
# config files can make use of as many variables as necessary.
# NOTE: ALL replacements will be attempted in ALL nginx config files (including
# snippets).
declare -A NGINX_CONF_VARS=(
    ['domain']='example.com'
    #['others']='place here'
)

#
# Options
#

DEPLOYMENT='dev'

TIME_ZONE='Australia/Sydney'

# A secret key will be generated automatically if not provided.
#SECRET_KEY=''

# A database password will be generated automatically if not provided.
#DB_PASS=''

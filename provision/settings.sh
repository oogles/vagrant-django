#!/usr/bin/env bash
# Project-specific settings used by the provisioning process

PROJECT_NAME=''

# Associative array of template values to replace in nginx config files. The
# default site configs use the "{{domain}}" variable. Custom config files can
# make use of as many variables as necessary.
# NOTE: ALL replacements will be attempted in ALL nginx config files (including
# snippets).
declare -A NGINX_CONF_VARS=(
    ['domain']=''
    #['others']='place here'
)

# The Python version to use for the project virtualenv. Leave blank to use the
# system version.
# Define an explicit version: BASE_PYTHON_VERSION='3.7.2'
BASE_PYTHON_VERSION=''

# List of additional Python versions to install (e.g. test with multiple
# versions via tox). If not included in the list, BASE_PYTHON_VERSION will be
# appended to the end.
# Define explicit versions: PYTHON_VERSIONS=('2.7.16' '3.5.6' '3.6.8')
PYTHON_VERSIONS=()

# Node.js version (major version only - the latest minor version will always be used)
NODE_VERSION='8'

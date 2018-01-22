#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

DISTRO=$(lsb_release -c -s)

echo " "
echo " --- Add/update apt repos ---"


echo " "
echo "Adding PostgreSQL repo..."

PG_SOURCE_LIST="/etc/apt/sources.list.d/pgdg.list"
if [[ ! -f "$PG_SOURCE_LIST" ]]; then
    curl -s https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
    echo "deb http://apt.postgresql.org/pub/repos/apt/ ${DISTRO}-pgdg main" > "$PG_SOURCE_LIST"
else
    echo "Already added."
fi


if [[ -f "$SRC_DIR/package.json" ]]; then
    echo " "
    echo "Adding node.js repo..."

    # Using NodeSource repo for node.js 5. For more details and other versions,
    # see NodeSource's full install scripts at:
    # https://github.com/nodesource/distributions/tree/master/deb

    NODE_SOURCE_LIST="/etc/apt/sources.list.d/nodesource.list"
    if [[ ! -f "$NODE_SOURCE_LIST" ]]; then
        curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
        echo "deb https://deb.nodesource.com/node_5.x ${DISTRO} main" > "$NODE_SOURCE_LIST"
    else
        echo "Already added."
    fi
fi


echo " "
echo "Updating..."
apt-get -qq update
echo "Done"

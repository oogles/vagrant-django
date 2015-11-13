#!/usr/bin/env bash

echo "Adding PostgreSQL repo..."
PG_REPO_APT_SOURCE=/etc/apt/sources.list.d/pgdg.list
if [[ ! -f "$PG_REPO_APT_SOURCE" ]]; then
    # Add PG apt repo:
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" > "$PG_REPO_APT_SOURCE"
    
    # Add PGDG repo key:
    wget --quiet -O - https://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc | apt-key add -
else
	echo "Already added."
fi

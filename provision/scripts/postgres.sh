#!/usr/bin/env bash

# Adapted from https://github.com/jackdb/pg-app-dev-vm

# Source global provisioning settings
source /tmp/env.sh

DB_USER="$PROJECT_NAME"
DB_NAME="$PROJECT_NAME"

print_db_usage () {
    echo " "
    echo "PostgreSQL database setup and accessible on your local machine on the forwarded port (default: 15432)"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: $DB_NAME"
    echo "  Username: $DB_USER"
    echo "  Password: $DB_PASS"
}

echo " "
echo " --- Install/configure PostgreSQL ---"

export DEBIAN_FRONTEND=noninteractive

if command -v psql >/dev/null; then
    echo "Already installed and configured."
    print_db_usage
    exit
fi

apt-get -qq install libpq-dev python-dev postgresql postgresql-contrib

echo " "
echo "Configuring..."
PG_VERSION=$(psql --version | egrep -o '[0-9]+\.[0-9]+')
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"

if [[ ! -f "$PG_CONF" ]]; then
    # Could not find config files in "<major_version>.<minor_version>/main"
    # directory, try just the "<major_version>/main" directory
    PG_VERSION=$(psql --version | egrep -o '[0-9]+' | head -1)
    PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
    PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
fi

if [[ ! -f "$PG_CONF" ]]; then
    # Still couldn't find the config files
    echo " "
    echo "--------------------------------------------------"
    echo "ERROR: Could not locate postgres config files."
    echo "Some configuration steps not performed."
    echo "--------------------------------------------------"
else
    # Edit postgresql.conf to change listen address to '*':
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

    # Append to pg_hba.conf to add password auth:
    echo "host    all             all             all                     md5" >> "$PG_HBA"

    # Explicitly set default client_encoding
    echo "client_encoding = utf8" >> "$PG_CONF"

    # Restart so that all new config is loaded
    service postgresql restart
fi

echo " "
echo "Creating \"$DB_NAME\" database..."
cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';

-- Create the database:
CREATE DATABASE $DB_NAME WITH OWNER=$DB_USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;

-- Give the database user permission to create databases, so it can be used
-- to create test databases
ALTER USER $DB_USER CREATEDB;
EOF

print_db_usage

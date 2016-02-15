#!/usr/bin/env bash

# Adapted from https://github.com/jackdb/pg-app-dev-vm

PROJECT_NAME="$1"

# Edit the following to change the name of the database user that will be created:
APP_DB_USER="$PROJECT_NAME"
APP_DB_PASS="$2"

# Edit the following to change the name of the database that is created (defaults to the user name)
APP_DB_NAME="$APP_DB_USER"

# Edit the following to change the version of PostgreSQL that is installed
PG_VERSION=9.4

print_db_usage () {
	echo " "
    echo "PostgreSQL database setup and accessible on your local machine on the forwarded port (default: 15432)"
    echo "  Host: localhost"
    echo "  Port: 5432"
    echo "  Database: $APP_DB_NAME"
    echo "  Username: $APP_DB_USER"
    echo "  Password: $APP_DB_PASS"
}

echo " "
echo " --- Install/configure PostgreSQL ---"

export DEBIAN_FRONTEND=noninteractive

if command -v psql; then
    echo "Already installed and configured."
    print_db_usage
    exit
fi

apt-get -qq install libpq-dev python-dev
apt-get -qq install "postgresql-$PG_VERSION" "postgresql-contrib-$PG_VERSION"

echo " "
echo "Configuring..."
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
PG_DIR="/var/lib/postgresql/$PG_VERSION/main"

# Edit postgresql.conf to change listen address to '*':
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"

# Append to pg_hba.conf to add password auth:
echo "host    all             all             all                     md5" >> "$PG_HBA"

# Explicitly set default client_encoding
echo "client_encoding = utf8" >> "$PG_CONF"

# Restart so that all new config is loaded
service postgresql restart

echo " "
echo "Creating \"$APP_DB_NAME\" database..."
cat << EOF | su - postgres -c psql
-- Create the database user:
CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS';

-- Create the database:
CREATE DATABASE $APP_DB_NAME WITH OWNER=$APP_DB_USER
                                  LC_COLLATE='en_US.utf8'
                                  LC_CTYPE='en_US.utf8'
                                  ENCODING='UTF8'
                                  TEMPLATE=template0;

-- Give the database user permission to create databases, so it can be used
-- to create test databases
ALTER USER $APP_DB_USER CREATEDB;
EOF

print_db_usage

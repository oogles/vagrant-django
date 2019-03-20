#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/settings.sh

function update_conf() {
    local file="$1"

    for key in "${!NGINX_CONF_VARS[@]}"; do
        local value=${NGINX_CONF_VARS[$key]}
        if [[ ! "$value" ]]; then
            echo "--------------------------------------------------"
            echo "ERROR: Empty value for nginx config variable \"$key\"."
            echo "--------------------------------------------------"
            exit 1
        fi

        # Replace all occurrences of $key with $value, using g to replace
        # multiple on the same line if necessary
        sed -i "s|{{$key}}|$value|g" "$file"
    done
}

echo " "
echo " --- Install nginx ---"

echo "Installing..."
apt-get -qq install nginx

# Create directory for logs
mkdir -p "$APP_DIR/logs/nginx/"

# Copy nginx.conf and any snippets
echo " "
echo "Copying nginx.conf..."
update_conf /tmp/conf/nginx/nginx.conf
cp /tmp/conf/nginx/nginx.conf /etc/nginx/

echo " "
echo "Copying snippets..."
snippet_dir="/tmp/conf/nginx/snippets"
if [[ ! -d "$snippet_dir" ]]; then
    echo "Nothing to copy"
else
    # Copy over changes and also delete obsolete files.
    # Using $snippet_dir in the for statement does not appear to work.
    for snippet in /tmp/conf/nginx/snippets/*.conf; do
        if [[ ! -e "$snippet" ]]; then continue; fi  # handle an empty directory
        update_conf "$snippet"
    done

    rsync -r --del "$snippet_dir/" "/etc/nginx/snippets/"
fi

echo " "
echo "Copying site config..."

# Copy the site config into sites-available
update_conf /tmp/conf/nginx/site
cp /tmp/conf/nginx/site "/etc/nginx/sites-available/$PROJECT_NAME"

# Link the copied site config into sites-enabled
if [[ ! -L "/etc/nginx/sites-enabled/$PROJECT_NAME" ]]; then
    ln -s "/etc/nginx/sites-available/$PROJECT_NAME" "/etc/nginx/sites-enabled/$PROJECT_NAME"
fi

# Remove the "default" site config from sites-enabled
if [[ -L "/etc/nginx/sites-enabled/default" ]]; then
    rm "/etc/nginx/sites-enabled/default"
fi

# Copy the separate secure site config as well, if provided.
# Do not enable it. See letsencrypt.sh for that.
secure_config="/tmp/conf/nginx/secure-site"
if [[ -f "$secure_config" ]]; then
    update_conf "$secure_config"
    cp "$secure_config" "/etc/nginx/sites-available/secure-$PROJECT_NAME"
fi

echo " "
echo "Stopping service (to be handled by supervisor)..."
service nginx stop

echo "Done"


# Only install gunicorn in production environments
if [[ "$DEBUG" -eq 0 ]]; then
    echo " "
    echo " --- Install gunicorn ---"

    echo "Installing..."
    su - webmaster -c "$VENV_ACTIVATE_CMD && pip install -q gunicorn"

    # Create directory for logs
    mkdir -p "$APP_DIR/logs/gunicorn/"

    echo " "
    echo "Copying conf.py..."

    # Copy conf.py to where it can be referenced by the gunicorn supervisor program
    mkdir -p /etc/gunicorn/
    cp "/tmp/conf/gunicorn/conf.py" "/etc/gunicorn/"

    echo "Done"
fi

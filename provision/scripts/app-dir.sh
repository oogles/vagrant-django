#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/settings.sh

echo " "
echo " --- Setup app directory structure (at $APP_DIR) ---"

# Ensure group read/write access to the app directory (the webmaster user is in
# the www-data group)
chmod 775 "$APP_DIR"

# Create the directory structure to store various project related files -
# required by the rest of the provisioning. Use -p to only create the directories
# if they don't already exist.
mkdir -p -m 775 "$APP_DIR/media/"
mkdir -p -m 775 "$APP_DIR/logs/"

if [[ "$DEBUG" -eq 0 ]]; then
    mkdir -p -m 775 "$APP_DIR/static/"
fi

# Create the special "ln" directory for shortcut links. See the added readme
# below for why. Start with a link to the Django project subdirectory (the
# project's Python package, where settings.py and wsgi.py live). Additional
# links are added as needed throughout the provisioning process.
ln_dir="$APP_DIR/ln"
mkdir -p -m 775 "$ln_dir"

project_subdir="$SRC_DIR/$PROJECT_NAME"
if [[ -d "$project_subdir" ]] && [[ ! -L "$ln_dir/package_dir" ]]; then
    ln -s "$project_subdir" "$ln_dir/package_dir"
fi

if [[ ! -f "$ln_dir/readme" ]]; then
cat <<EOF > "$ln_dir/readme"
This directory is primarily used to simplify the process of configuring the server.
It acts as a container for shortcut symlinks to various project-specific files and
directories (i.e. those that contain the project name).

It is designed to allow using known paths in config files, without forcing
customisation in projects that would not otherwise need it (it avoids requiring
the modification of a series of paths to include the project name).
EOF
fi

# Set ownership of everything in the app directory
chown www-data:www-data -R "$APP_DIR"

# Update the webmaster user's profile to automatically change to the project
# source directory when they SSH in
if ! grep -Fxq "cd $SRC_DIR" /home/webmaster/.profile ; then
    echo -e "\n# Change into the $PROJECT_NAME source directory by default\ncd $SRC_DIR" >> /home/webmaster/.profile
fi

echo "Done"

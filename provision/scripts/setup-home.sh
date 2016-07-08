#!/usr/bin/env bash

PROJECT_NAME="$1"

echo " "
echo " --- Setup vagrant user home directory ---"

echo "Creating /home/vagrant/$PROJECT_NAME/..."
# Create directories to store nginx and gunicorn logs, collected static files,
# and uploaded media files
if [[ ! -d "/home/vagrant/$PROJECT_NAME/" ]] ; then
    su vagrant <<EOF
mkdir -p "/home/vagrant/$PROJECT_NAME/logs/nginx/"
mkdir -p "/home/vagrant/$PROJECT_NAME/logs/gunicorn/"
mkdir -p "/home/vagrant/$PROJECT_NAME/static/"
mkdir -p "/home/vagrant/$PROJECT_NAME/media/"
EOF

    echo "Done"
else
    echo "Already exists"
fi


echo " "
echo "Copying config files..."
if [[ -d /vagrant/provision/conf/user/ ]]; then
    # Copy all contents of conf/user/ to the vagrant user's home directory,
    # without updating/replacing existing files.
    
    su vagrant <<EOF
shopt -s dotglob nullglob
cp -n /vagrant/provision/conf/user/* ~/
shopt -u dotglob nullglob
EOF
    
    echo "Done"

fi


echo " "
echo "Adding custom scripts..."
if [[ ! -d /home/vagrant/bin/ ]] ; then
    su - vagrant -c "mkdir ~/bin"
fi

su - vagrant -c "cp -n /vagrant/provision/scripts/bin/* ~/bin/"

echo "Done"

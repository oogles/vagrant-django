#!/usr/bin/env bash

DEBUG="$1"

echo " "
echo " --- Setup vagrant user home directory ---"

echo "Creating /home/vagrant/proj/..."
# Create directories to store various project related files
if [[ ! -d "/home/vagrant/proj/" ]]; then
    mkdir /home/vagrant/proj/
    
    mkdir /home/vagrant/proj/media/
    
    if [[ "$DEBUG" -eq 0 ]]; then
        mkdir /home/vagrant/proj/static/
        mkdir -p /home/vagrant/proj/logs/nginx/
        mkdir -p /home/vagrant/proj/logs/gunicorn/
    fi
    
    chown -R vagrant:vagrant /home/vagrant/proj/
    
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
if [[ ! -d /home/vagrant/bin/ ]]; then
    su - vagrant -c "mkdir ~/bin"
fi

su - vagrant -c "cp -n /vagrant/provision/scripts/bin/* ~/bin/"

echo "Done"

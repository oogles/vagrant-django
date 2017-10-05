#!/usr/bin/env bash

# Source global provisioning settings
source /tmp/env.sh

echo " "
echo " --- Setup user ---"

echo "Creating \"webmaster\" user..."
if id webmaster >/dev/null 2>&1; then
    echo "Already exists"
else
    # Create a webmaster group first
    groupadd webmaster

    # Create the user as a member of both the webmaster and www-data groups,
    # and the bash shell for when they SSH in
    useradd -g webmaster -G www-data -s /bin/bash -m webmaster
fi


echo " "
echo "Granting it superuser permissions..."
if [[ "$DEBUG" -eq 1 ]]; then
    # For development environments, edit sudoers to include the "webmaster"
    # user, without requiring password entry (for ease of use).
    if grep -q webmaster /etc/sudoers ; then
        echo "Already granted"
    else
        echo "webmaster ALL=(ALL:ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)
    fi
else
    # For production environments, simply add the user to the "sudo" group,
    # which is already granted full admin privileges, and requires the user's
    # password.
    usermod -aG sudo webmaster
    echo "Done"
fi


echo " "
echo " Copying files to home directory..."

if [[ ! -d "$PROVISION_DIR/conf/user/" ]]; then
    echo "Nothing to copy"
else
    # Copy all contents of conf/user/ to the webmaster user's home directory.
    # Use rsync to change ownership at the same time (as chown -R in the
    # destination directory is not viable here), and to avoid needing to use
    # "shopt -s dotglib" to enable cp to pick up dotfiles.
    rsync -r -og --chown=webmaster:webmaster "$PROVISION_DIR/conf/user/" /home/webmaster/

    # Make the bin/ scripts executable
    chmod u+x -R /home/webmaster/bin/
fi

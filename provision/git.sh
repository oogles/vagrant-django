echo " "
echo " --- git ---"

apt-get install -y git

if [ -f /vagrant/provision/config/.gitconfig ]; then
	su - vagrant -c "cp /vagrant/provision/config/.gitconfig ~/.gitconfig"
else
	echo " "
	echo "--------------------------------------------------"
	echo "WARNING: No .gitconfig found in provision/config/."
	echo "Git environment not configured."
	echo "--------------------------------------------------"
fi

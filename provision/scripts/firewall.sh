echo " "
echo " --- Set firewall rules ---"
if [[ -f /vagrant/provision/conf/firewall-rules.conf ]]; then
    # Enable IPv6
    if grep -Fxq "IPV6=no" /etc/default/ufw ; then
        echo "Enabling IPv6"
        sudo sed -i 's|IPV6=no|IPV6=yes|g' /etc/default/ufw
        
        # Disable in case already enabled. Will be re-enabled below.
        ufw disable
    fi
    
    while read -r line; do
        [[ $line = \#* ]] && continue
        ufw $line
    done < /vagrant/provision/conf/firewall-rules.conf
    
    # Enable (or re-enable in case of re-provisioning)
    ufw --force enable
    
    # Print the status
    ufw status verbose
else
    echo "None found."
fi

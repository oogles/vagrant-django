# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Reference: https://docs.vagrantup.com.

  config.vm.box = "ubuntu/trusty32"

  config.vm.provision "shell" do |s|
    s.path = "provision/scripts/bootstrap.sh"
    
    # For a full Django project
    s.args = ["project_name", "project"]
    
    # For a single app
    #s.args = ["project_name", "app"]
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 80, host: 8080
  
  # Postgres
  config.vm.network "forwarded_port", guest: 5432, host: 15432
  
  # Add a few ports for runserver use
  config.vm.network "forwarded_port", guest: 8460, host: 8460
  config.vm.network "forwarded_port", guest: 8461, host: 8461
  config.vm.network "forwarded_port", guest: 8462, host: 8462

  # Provider-specific configuration
  #config.vm.provider "virtualbox" do |vb|
  #  # Display the VirtualBox GUI when booting the machine
  #  #vb.gui = true
  #  
  #  # Customize the amount of memory on the VM:
  #  #vb.memory = "1024"
  #end

end

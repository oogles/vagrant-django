# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANT_COMMAND = ARGV[0]

Vagrant.configure(2) do |config|
  # Reference: https://docs.vagrantup.com.

  # Use the "webmaster" user for SSH
  if VAGRANT_COMMAND == "ssh"
    config.ssh.username = "webmaster"
    config.ssh.keys_only = false  # enable use of keys in ssh-agent
  end

  config.vm.box = "bento/ubuntu-18.04"

  config.vm.synced_folder ".", "/opt/app/src",
    owner: "www-data",
    group: "www-data",
    mount_options: ["dmode=775"]  # ensure group read/write access for webmaster user

  config.vm.provision "shell" do |s|
    s.path = "provision/scripts/bootstrap.sh"
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

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "icpc-environment-base32"
  config.vm.box_url = "https://dl.dropboxusercontent.com/s/ey5nf3s20eses0g/icpc-environment-base32.box"
  config.vm.network :private_network, ip: "192.168.33.33"

  config.vm.synced_folder "dist", "/dist"

  config.vm.provider "virtualbox" do |v|
    v.gui = true
  end

  config.vm.provision "chef_solo" do |chef|
    chef.log_level = :debug
    chef.cookbooks_path = ["chef/site-cookbooks", "chef/cookbooks"]
    chef.roles_path = "chef/roles"
    chef.data_bags_path = "chef/data_bags"
    chef.add_role "icpc-environment"

    chef.add_recipe "apt::cacher-client"
  end
end

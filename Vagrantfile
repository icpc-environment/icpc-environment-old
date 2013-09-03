# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
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

    chef.json = {
      "apt" => {
       "cacher_ipaddress" => "10.0.0.16"
      }
    }
    chef.add_recipe "apt::cacher-client"
  end
end

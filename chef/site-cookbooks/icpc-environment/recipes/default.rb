#
# Cookbook Name:: icpc-contestant
# Recipe:: default
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

# No apt caches
bash "remove caches" do
	code <<-EOF
		rm -f /var/cache/apt/*.bin
	EOF
end
template "/etc/apt/apt.conf.d/02nocache" do
	source "02nocache.erb"
	owner "root"
	group "root"
	mode "0644"
end

# Things we can safely remove
%w{apt-xapian-index libxapian22 python-xapian}.each do |pkg|
	package pkg do
		action :purge
	end
end
execute "remove xapian index" do
	command "rm -rf /var/cache/apt-xapian-index/*"
end

# Install the essential development tools(compilers/runtimes/etc)
include_recipe "icpc-environment::devel-tools"

# Install the gui environment
include_recipe "icpc-environment::gui-env"

# Install eclipse
include_recipe "icpc-environment::eclipse"

# Documentation for the various languages
include_recipe "icpc-environment::lang-docs"


# udev Persistent-net fix(this keeps eth0 from changing names)
bash "udev persistent net disable" do
	code <<-EOF
		rm -f /etc/udev/rules.d/70-persistent-net.rules
		ln -s /dev/null /etc/udev/rules.d/75-persistent-net-generator.rules
	EOF
	not_if "test -h /etc/udev/rules.d/75-persistent-net-generator.rules"
end

# Setup the firewall
include_recipe "icpc-environment::firewall"

# random contest requirements(users, scripts, etc)
include_recipe "icpc-environment::contest-requirements"

#######################
####### CLEANUP #######
#######################
# Crap that can be removed
# xscreensaver - 872kb
# yelp         - 63mb
%w{xscreensaver yelp gnome-keyring desktop-base}.each do |pkg|
	package pkg do
		action :purge
	end
end

# Possibly run localepurge(set to 'en'); freed about 45mb


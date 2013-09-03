#
# Cookbook Name:: icpc-contestant
# Recipe:: contest-requirements
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

# Free up some space(on a 4gb image we don't have a lot to work with)
execute "apt-get clean"

# Copy our xorg.conf, which disables screen blanking/power management
template "/etc/X11/xorg.conf" do
	source "xorg.conf.erb"
	mode "0644"
end

# Set the timezone
tzdata = data_bag_item("contestenv",node['contestenv']['databag'])['tzdata']
execute "update-tzdata" do
	command "dpkg-reconfigure -f noninteractive tzdata"
	action :nothing
end
file "/etc/timezone" do
	owner "root"
	group "root"
	mode "0644"
	content tzdata
	notifies :run, "execute[update-tzdata]"
end

include_recipe "icpc-environment::scripts"

######################################
### Packages
# git          - provisioning home directories(can be removed later)
# ufw          - configuring the firewall
# imagemagick  - (46mb) generating the team background image
# gksu         - Letting us run as root
# ntp          - keeping the time in sync
# cups         - needed for printing
# cups-bsd     - printing stuff(provides lpr for enscript)
# enscript     - for page numbering
# pdftk        - for cups filters
%w{ufw imagemagick gksu git ntp cups cups-bsd pdftk enscript}.each do |pkg|
	package pkg
end

# set up cups to watermark all pages
#cookbook_file "/usr/lib/cups/filter/watermark_printout" do
#	source "watermark_printout.sh"
#	owner "root"
#	group "root"
#	mode "0755"
#end
#cookbook_file "/usr/share/cups/mime/local.convs" do
#	source "local.convs"
#	owner "root"
#	group "root"
#	mode "0644"
#end

######################################
### Create the contestant user

# Pull in the skel directory from a git repository
execute "rm -rf /etc/skel" do
	not_if "test -d /etc/skel/.git"
end
git "/etc/skel" do
	repository "#{node['contestenv']['contestant_home_repo']}"
end

# Create the contestant user(and remove their password)
execute "delete-contestant-password" do
	command "passwd -d #{node['contestenv']['username']}"
	action :nothing
end
user "#{node['contestenv']['username']}" do
	comment "Contestant"
	shell "/bin/bash"
	home "/home/#{node['contestenv']['username']}"
	supports :manage_home=>true
	notifies :run, resources(:execute => "delete-contestant-password"), :immediately
end

######################################
### Create the admin user
# Generate the proper password hash for setting the password
admin_info = data_bag_item("contestenv",node['contestenv']['databag'])['admin_info']
admin_passwordhash=admin_info['password'].crypt("$6$#{admin_info['salt']}")

# Create admin user(ruby-shadow is needed for this)
gem_package "ruby-shadow"
user "#{admin_info['username']}" do
	comment "Admin"
	password admin_passwordhash
	shell "/bin/bash"
	home "/home/#{admin_info['username']}"
end
# add them to the printer admin group
group "lpadmin" do
	action :modify
	members admin_info['username']
	append true
end

# Give them nopasswd sudo access
template "/etc/sudoers.d/#{admin_info['username']}" do
	source "admin.sudo"
	mode "0440"
	owner "root"
	group "root"
	variables( :admin_username => admin_info['username'] )
end

# Admin home directory comes from a git repository too
bash "#{admin_info['username']} home" do
	code <<-EOF
		rm -rf /home/#{admin_info['username']}
		mkdir /home/#{admin_info['username']}
		chown #{admin_info['username']}:#{admin_info['username']} /home/#{admin_info['username']}
	EOF
	not_if "test -d /home/#{admin_info['username']}/.git"
end
git "/home/#{admin_info['username']}" do
	repository "#{node['contestenv']['admin_home_repo']}"
	user admin_info['username']
	group admin_info['username']
end

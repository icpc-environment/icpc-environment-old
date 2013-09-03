#
# Cookbook Name:: icpc-contestant
# Recipe:: gui-env
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

# Graphical UI(XFCE with the LightDM login manager)
%w{xfce4 lightdm xfce4-power-manager}.each do |pkg|
	package pkg
end

# Lightdm configuration(autologin/etc)
template "/etc/lightdm/lightdm.conf" do
	source "lightdm.conf.erb"
	owner "root"
	group "root"
	mode "0644"
end

# Tools for programmers
# firefox               - 40mb
# vim-gtk               - 15mb
# gedit                 - 15mb
# emacs                 - 29mb?
# flashplugin-installer - 3mb
%w{firefox vim-gtk gedit emacs flashplugin-installer}.each do |pkg|
	package pkg
end

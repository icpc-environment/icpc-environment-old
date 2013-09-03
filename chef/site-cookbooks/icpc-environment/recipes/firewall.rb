#
# Cookbook Name:: icpc-contestant
# Recipe:: firewall
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

fw_rules = data_bag_item("contestenv", node['contestenv']['databag'])['fw_rules']

firewall_rule "FW Allow SSH" do
    protocol :tcp
    port 22
    action :allow
    direction :in
end

# ufw default deny outgoing
execute "ufw default deny outgoing"

allowed_sites = fw_rules['allowed_sites']
allowed_sites.each do |host|
    firewall_rule "FW Allow Website '#{host}" do
        protocol :tcp
        dest_port 80
        destination host
        direction :out
        action :allow
    end
end

firewall_rule "FW Allow Printing" do
    protocol :tcp
    dest_port 9100
    direction :out
    action :allow
end

firewall_rule "FW Allow DHCP(67)" do
    protocol :udp
    dest_port 67
    direction :out
    action :allow
end

firewall_rule "FW Allow DHCP(68)" do
    protocol :udp
    dest_port 68
    direction :out
    action :allow
end

firewall_rule "FW Allow DNS" do
    protocol :udp
    dest_port 53
    direction :out
    action :allow
end

firewall_rule "FW Allow NTP" do
    protocol :udp
    dest_port 123
    direction :out
    action :allow
end

# enable the firewall (leave this to the makedist script)
#firewall "ufw" do
#    action :enable
#end
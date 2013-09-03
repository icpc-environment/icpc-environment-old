#
# Cookbook Name:: icpc-contestant
# Recipe:: devel-tools
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

# ghc        - 290mb
# fpc        - 283mb
# python     - ???
# gnat       - 176mb
# gfortran   - 17mb
# mono-gmcs  - 22mb
# Essential compilers/etc(Should match similar line in domjudge/attributes/defaults.rb)
%w{build-essential ghc fpc python gnat gfortran mono-mcs mono-gmcs python3 lua5.2}.each do |pkg|
	package pkg
end

# Install tcsh, needed by some benchmarking scripts we have(and maybe desirable to the teams)
package "tcsh"
package "gawk"

#######################
### Oracle Java JDK ###
apt_repository "webupd8team" do
	uri "http://ppa.launchpad.net/webupd8team/java/ubuntu"
	distribution node['lsb']['codename']
	components ['main']
	keyserver "keyserver.ubuntu.com"
	key "EEA14886"
end
package "oracle-java7-installer" do
	response_file "oracle-java7-installer.preseed"
end

bash "cleanup java install" do
	code <<-EOF
		rm -rf /var/cache/oracle-jdk7-installer/
	EOF
	only_if "test -d /var/cache/oracle-jdk7-installer/"
end

#######################
###      Scala      ###
#######################
remote_file "#{Chef::Config[:file_cache_path]}/scala.tgz" do
	source "http://www.scala-lang.org/files/archive/scala-2.10.2.tgz"
end
bash "extract scala" do
	cwd '/opt/'
	code <<-EOF
		mkdir -p /opt/scala
		tar zxf "#{Chef::Config[:file_cache_path]}/scala.tgz" --no-same-owner --strip-components=1 -C /opt/scala
		chmod +x /opt/scala/bin/*
		update-alternatives --install "/usr/bin/scalac" "scalac" "/opt/scala/bin/scalac" 1
		update-alternatives --install "/usr/bin/scala" "scala" "/opt/scala/bin/scala" 1
	EOF
	not_if "test -d /opt/scala"
end

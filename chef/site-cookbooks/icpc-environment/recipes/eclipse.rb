#
# Cookbook Name:: icpc-contestant
# Recipe:: eclipse
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

## Eclipse
eclipse_src = ''
eclipse_archive = '/tmp/eclipse.tar.gz'
case node[:kernel][:machine]
	when "x86_64"
		eclipse_src = node['contestenv']['eclipse64']
	when "i686"
		eclipse_src = node['contestenv']['eclipse32']
end

if eclipse_src.start_with?"/" then
	execute "cp \"#{eclipse_src}\" \"#{eclipse_archive}\"" do
		not_if "test -d /opt/eclipse"
	end
else
	remote_file "#{eclipse_archive}" do
		source eclipse_src
		not_if "test -d /opt/eclipse"
	end
end

bash "Install eclipse" do
	cwd "/opt"
	code <<-EOF
		tar -zxf #{eclipse_archive} -C /opt/
		chown -R root:root /opt/eclipse
		rm #{eclipse_archive}
	EOF
	not_if "test -d /opt/eclipse"
end

## Eclipse plugins
# Runs eclipse and tells it to download/install the specific plugins from their respective repositories
# Ref: http://stackoverflow.com/questions/7163970/how-do-you-automate-the-installation-of-eclipse-plugins-with-command-line

# pydev(Needs its own certificate)
remote_file "/opt/pydev_certificate.cer" do
	source "http://pydev.org/pydev_certificate.cer"
	checksum "acff1a88730cbec3ccc23188021b4977cb2209b41de44ca32990d721a65ebe08"
end
bash "Install PyDev Eclipse plugin" do
	cwd "/opt"
	code <<-EOF
		. /etc/profile.d/java_path.sh
		keytool -import -file /opt/pydev_certificate.cer -noprompt -storepass changeit -keystore /usr/lib/jvm/jdk*/jre/lib/security/cacerts
		/opt/eclipse/eclipse -nosplash \
			-application org.eclipse.equinox.p2.director \
			-repository http://pydev.org/updates/ \
			-destination /opt/eclipse \
			-installIU org.python.pydev.feature.feature.group | grep -v DEBUG
	EOF
	not_if "test -d /opt/eclipse/features/org.python.pydev.feature_*"
end
# C/C++ Development plugin for eclipse
bash "Install CDT Eclipse Plugin" do
	cwd "/opt"
	code <<-EOF
		. /etc/profile.d/java_path.sh
		/opt/eclipse/eclipse -nosplash \
			-application org.eclipse.equinox.p2.director \
			-repository http://download.eclipse.org/tools/cdt/releases/juno/ \
			-destination /opt/eclipse \
			-installIU org.eclipse.cdt.feature.group \
			-installIU org.eclipse.cdt.platform.feature.group | grep -v DEBUG
	EOF
	not_if "test -d /opt/eclipse/features/org.eclipse.cdt.platform_*"
end

# Application entry for eclipse
cookbook_file "/usr/share/applications/Eclipse.desktop" do
	source "Eclipse.desktop"
	mode "0644"
end
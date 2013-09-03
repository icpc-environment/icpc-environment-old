#
# Cookbook Name:: icpc-contestant
# Recipe:: lang-docs
#
# Copyright 2012, Keith Johnson
#
# All rights reserved - Do Not Redistribute
#

# Documentation for programming languages
# stl-manual    - 4mb		(/usr/share/doc/stl-manual/html/index.html)
# openjdk-7-doc - 246mb		(/usr/share/openjdk-7-doc/api/index.html)
# python-doc    - 32mb		(/usr/share/doc/python-doc/html/index.html)
# fp-docs       - 40mb		(/usr/share/doc/fp-docs/2.4.0/fpctoc.html)
# ghc-doc       - 60mb		(/usr/share/doc/ghc-doc/index.html)
%w{python-doc stl-manual fp-docs openjdk-7-doc ghc-doc}.each do |pkg|
	package pkg
end

# Generate a page with links to all the documentation
template "/opt/language-docs.html" do
	source "language-docs.html.erb"
	mode "0644"
end

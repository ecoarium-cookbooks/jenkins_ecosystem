#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: java
#

case node['platform']
when 'redhat', 'centos', 'fedora'
  include_recipe 'java'
when 'mac_os_x'
  include_recipe 'java-osx'
when 'windows'
  include_recipe 'java-windows'
else
  Chef::Application.fatal!("this OS is not supported: #{node['platform']}")
end

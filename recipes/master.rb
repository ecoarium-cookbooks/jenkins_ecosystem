#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: default
#

include_recipe 'jenkins_ecosystem::credentials'

include_recipe 'jenkins_ecosystem::base'
include_recipe 'jenkins_ecosystem::apache2'

include_recipe 'jenkins::master'

jenkins_ecosystem_wait_until_up 'wait for meeeeeee'

jenkins_server_confg_file_path = "#{node[:jenkins_ecosystem][:home]}/config.xml"

log 'show config' do
  message lazy { File.read(jenkins_server_confg_file_path) }
end

log 'first run configuration...' do
  notifies :create, 'cookbook_file[lay down server config for first run]', :immediately
  notifies :create, 'cookbook_file[lay down admin config for first run]', :immediately
  notifies :create, 'file[lay down install flag file]', :immediately

  notifies :restart, 'service[jenkins]', :immediately
  notifies :wait, 'jenkins_ecosystem_wait_until_up[wait for meeeeeee]', :immediately
  only_if "grep '<slaveAgentPort>-1</slaveAgentPort>' '#{jenkins_server_confg_file_path}'"
end

cookbook_file 'lay down server config for first run' do
  path jenkins_server_confg_file_path
  source 'server-config.xml'
  owner 'jenkins'
  group 'jenkins'
  action :nothing
end

cookbook_file 'lay down admin config for first run' do
  path "#{node[:jenkins_ecosystem][:home]}/users/admin/config.xml"
  source 'admin-config.xml'
  owner 'jenkins'
  group 'jenkins'
  action :nothing
end

file 'lay down install flag file' do
  path "#{node[:jenkins_ecosystem][:home]}/jenkins.install.InstallUtil.lastExecVersion"
  owner 'jenkins'
  group 'jenkins'
  content lazy{ File.read("#{node[:jenkins_ecosystem][:home]}/jenkins.install.UpgradeWizard.state") }
  action :nothing
end

jenkins_command 'reload-configuration' do
  action :nothing
end

include_recipe 'jenkins_ecosystem::plugins'

node[:jenkins_ecosystem][:customization][:master][:recipes].each{|recipe|
  include_recipe recipe
}

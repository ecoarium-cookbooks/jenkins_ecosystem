#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: slave_centos
#

include_recipe 'jenkins_ecosystem::credentials'


if node[:jenkins_ecosystem][:slave][:name].nil?
  Chef::Application.fatal!('the slave name attribute has not been set
a slave name is required, please set the attribute:

  node[:jenkins_ecosystem][:slave][:name]

')
end

include_recipe 'jenkins_ecosystem::java_attributes'

node.override['jenkins']['java'] = "#{node[:java][:java_home]}/bin/java"

jenkins_slave node[:jenkins_ecosystem][:slave][:name] do
  action :disconnect
  only_if 'which java #lame check to skip if this is the first run and java is not yet installed'
end

include_recipe 'jenkins_ecosystem::base'

jenkins_jnlp_slave node[:jenkins_ecosystem][:slave][:name] do
  remote_fs   node[:jenkins_ecosystem][:home]
  labels      node[:jenkins_ecosystem][:customization][:slave][:labels]
  executors   node[:jenkins_ecosystem][:customization][:slave][:executors]
  usage_mode  node[:jenkins_ecosystem][:customization][:slave][:usage_mode]
  java_path   "/usr/java/latest/bin/java"
end

jenkins_slave node[:jenkins_ecosystem][:slave][:name] do
  action :connect
end

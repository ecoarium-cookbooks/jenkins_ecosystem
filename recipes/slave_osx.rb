#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: slave_osx
#

include_recipe 'jenkins_ecosystem::credentials'

include_recipe 'jenkins_ecosystem::java'
include_recipe 'jenkins_ecosystem::sudo'

user 'jenkins' do
  action :create
  home node[:jenkins_ecosystem][:home]
  shell '/bin/bash'
  supports :manage_home => true
end

group 'jenkins' do
  action :create
  members ['jenkins']
end

execute 'add_jenkins_to_admin' do
  command 'sudo /usr/sbin/dseditgroup -o edit -a jenkins -t user admin'
  action :run
end

file 'create_git_credentials_file' do
  path "#{node[:jenkins_ecosystem][:home]}/.netrc"
  owner 'jenkins'
  group 'jenkins'
  mode '0600'
  content "machine #{node[:jenkins_ecosystem][:git][:domain]} login #{data_bag_item('credentials', 'jenkins')[:username]} password #{data_bag_item('credentials', 'jenkins')[:password]}"
end

if node[:jenkins_ecosystem][:slave][:name].nil?
  Chef::Application.fatal!('the slave name attribute has not been set
a slave name is required, please set the attribute:

  node[:jenkins_ecosystem][:slave][:name]

')
end

file "/var/log/jenkins-slave-out.log" do
  action :create_if_missing
  owner "jenkins"
  group "jenkins"
end

file "/var/log/jenkins-slave-error.log" do
  action :create_if_missing
  owner "jenkins"
  group "jenkins"
end

jenkins_jnlp_slave_osx node[:jenkins_ecosystem][:slave][:name] do
  remote_fs   node[:jenkins_ecosystem][:home]
  labels      node[:jenkins_ecosystem][:customization][:slave][:labels]
  executors   node[:jenkins_ecosystem][:customization][:slave][:executors]
  usage_mode  node[:jenkins_ecosystem][:customization][:slave][:usage_mode]
  java_path   "#{node[:java][:osx_dmg][:java_home]}/bin/java"
end

jenkins_slave node[:jenkins_ecosystem][:slave][:name] do
  action :connect
end

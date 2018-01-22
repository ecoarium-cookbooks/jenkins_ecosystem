#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: slave_windows
#
node.override[:jenkins_ecosystem][:home] = 'C:/Users/jenkins'

include_recipe 'jenkins_ecosystem::base_attributes'
include_recipe 'jenkins_ecosystem::credentials'
include_recipe 'jenkins_ecosystem::java'

if node[:jenkins_ecosystem][:slave][:name].nil?
  Chef::Application.fatal!('the slave name attribute has not been set
a slave name is required, please set the attribute:

  node[:jenkins_ecosystem][:slave][:name]

')
end

node.override['jenkins']['java'] = "#{node[:java][:windows][:java_home]}\\bin\\java"

jenkins_slave node[:jenkins_ecosystem][:slave][:name] do
  action :disconnect
  only_if 'which java #lame check to skip if this is the first run and java is not yet installed'
end

user 'jenkins' do
  action :create
  home node[:jenkins_ecosystem][:home]
  supports :manage_home => true
  password 'Vagrant.4321'
  system true
end

group 'Administrators' do
  action :modify
  members 'jenkins'
  append true
end

powershell_script 'create user profile' do
  code <<-EOH
    $userName="jenkins"
    $password="Vagrant.4321"

    $spw = ConvertTo-SecureString $password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $userName,$spw
    Start-Process cmd /c -Credential $cred -ErrorAction SilentlyContinue -LoadUserProfile
  EOH
end


include_recipe 'jenkins_ecosystem::aws'
include_recipe 'jenkins_ecosystem::esxi'

ruby_version = '2.2.4'
ruby_binary_path = "#{node[:jenkins_ecosystem][:home]}/.rbenv/versions/#{ruby_version}/bin/ruby"

file 'create_git_credentials_file' do
  path "#{node[:jenkins_ecosystem][:home]}/.netrc"
  owner 'jenkins'
  group 'jenkins'
  mode '0600'
  content "machine #{node[:jenkins_ecosystem][:git][:domain]} login #{data_bag_item('credentials', 'jenkins')[:username]} password #{data_bag_item('credentials', 'jenkins')[:password]}"
end

execute 'enable_git_longpath' do
  command 'git config --system core.longpaths true'
end

jenkins_windows_slave node[:jenkins_ecosystem][:slave][:name] do
  remote_fs   '/var/lib/jenkins'
  labels      node[:jenkins_ecosystem][:customization][:slave][:labels]
  executors   node[:jenkins_ecosystem][:customization][:slave][:executors]
  usage_mode  node[:jenkins_ecosystem][:customization][:slave][:usage_mode]
  java_path   node['jenkins']['java']
  path 'C:\usr\local\.rbenv\shims;C:\usr\local\ruby-install\bin;C:\usr\local\rbenv\libexec;C:\tools\msys\20160205-3\cmd;C:\tools\Sysinternals;C:\Users\vagrant\bin;C:\Users\vagrant\.rbenv\versions\2.2.4\bin;\cmd;\usr\local\bin;\mingw64\bin;\usr\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0;\usr\bin\site_perl;\usr\bin\vendor_perl;\usr\bin\core_perl'
  user 'jenkins'
  password   'Vagrant.4321'
  pre_run_cmds ['set MSYS=winsymlinks:nativestrict']
end

jenkins_slave node[:jenkins_ecosystem][:slave][:name] do
  action :connect
end

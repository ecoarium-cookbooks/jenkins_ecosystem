#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: base
#

include_recipe 'jenkins_ecosystem::base_attributes'

include_recipe 'git::source'

include_recipe 'jenkins_ecosystem::java'

user 'jenkins' do
  action :create
  home node[:jenkins_ecosystem][:home]
  shell '/bin/bash'
  supports :manage_home => true
end

directory node[:jenkins_ecosystem][:home] do
  owner 'jenkins'
  group 'jenkins'
  action :create
end

group 'jenkins' do
  action :create
  members ['jenkins']
end

include_recipe 'jenkins_ecosystem::sudo'
include_recipe 'jenkins_ecosystem::aws'
include_recipe 'jenkins_ecosystem::esxi'

ruby_version = '2.2.4'
ruby_binary_path = "#{node[:jenkins_ecosystem][:home]}/.rbenv/versions/#{ruby_version}/bin/ruby"

bash 'install_ruby' do
  user 'jenkins'
  group 'jenkins'
  cwd node[:jenkins_ecosystem][:home]
  code %^
sudo su - jenkins <<-'ENDCOMMANDS'
  eval "$(rbenv init - )"

  rbenv install "#{ruby_version}"
ENDCOMMANDS
^
  creates ruby_binary_path
end

link '/usr/local/bin/ruby' do
  to ruby_binary_path
  link_type :symbolic
end

link '/bin/bsdtar' do
  to '/bin/tar'
  link_type :symbolic
  not_if 'which bsdtar'
end

file 'create_git_credentials_file' do
  path "#{node[:jenkins_ecosystem][:home]}/.netrc"
  owner 'jenkins'
  group 'jenkins'
  mode '0600'
  content "machine #{node[:jenkins_ecosystem][:git][:domain]} login #{data_bag_item('credentials', 'jenkins')[:username]} password #{data_bag_item('credentials', 'jenkins')[:password]}"
end

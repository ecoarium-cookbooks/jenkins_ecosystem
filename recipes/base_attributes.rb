#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: base_attributes
#

include_recipe 'chef_commons'

node.override['build-essential'][:compile_time] = true

node.override[:git].deep_merge!(node[:jenkins_ecosystem][:git])

node.override[:jenkins][:master][:home] = node[:jenkins_ecosystem][:home]

node.override[:jenkins][:master][:jvm_options] = '-Dhudson.model.DirectoryBrowserSupport.CSP= -Xmx256m'

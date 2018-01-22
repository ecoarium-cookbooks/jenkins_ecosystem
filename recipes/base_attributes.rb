#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: base_attributes
#

include_recipe 'chef_commons'

node.override['build-essential'][:compile_time] = true

node.override[:git].deep_merge!(node[:jenkins_ecosystem][:git])

node.override[:jenkins][:master][:home] = node[:jenkins_ecosystem][:home]

def disable_configuring_content_security_policy
  # https://wiki.jenkins.io/display/JENKINS/Configuring+Content+Security+Policy
  node.override[:jenkins][:master][:jvm_options] = "#{node[:jenkins][:master][:jvm_options]} -Dhudson.model.DirectoryBrowserSupport.CSP="
end

disable_configuring_content_security_policy

def set_maximum_java_heap_size
  node.override[:jenkins][:master][:jvm_options] = "#{node[:jenkins][:master][:jvm_options]} -Xmx#{node[:jenkins_ecosystem][:jvm][:options][:xmx]}"
end

set_maximum_java_heap_size

node.override[:jenkins][:master][:version] = node[:jenkins_ecosystem][:version]

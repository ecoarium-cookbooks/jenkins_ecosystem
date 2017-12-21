#
# Cookbook Name:: rest
# Recipe:: apache2
#

fqdn = node[:jenkins_ecosystem][:fqdn]

if fqdn.nil?
  server = data_bag_item(node[:jenkins_ecosystem][:server][:data_bag], node[:jenkins_ecosystem][:server][:data_bag_item])
  fqdn = server[:fqdn]
end

include_recipe "selinux::permissive"

node.override[:apache].deep_merge!({
  default_site_enabled: false,
  package: "httpd",
  listen: [
    "*:443"
  ]
})

node.include_attribute('apache2')

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_headers"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"

directory node[:apache][:ssl_dir] do
  owner node[:apache][:user]
  group node[:apache][:group]
  recursive true
  action :create
end

ssl_certs fqdn do
  notifies :restart, 'service[apache2]'
end

web_app "jenkins.apache.config" do
  template "apache.conf.erb"
  server_name fqdn
  document_root node[:apache][:root_dir]
  ssl_cert_file node[:apache][:ssl_cert_file]
  ssl_cert_key_file node[:apache][:ssl_cert_key_file]
  ssl_cert_chain_file node[:apache][:ssl_cert_chain_file] if node[:apache].has_key?(:ssl_cert_chain_file)
end
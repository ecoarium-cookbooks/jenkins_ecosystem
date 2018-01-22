#
# Cookbook Name:: jenkins_ecosystem
# Attributes:: default
#
#

default[:jenkins_ecosystem][:version] = '2.50-1.1'
default[:jenkins_ecosystem][:home] = '/var/lib/jenkins'

default[:jenkins_ecosystem][:slave][:name] = nil

default[:jenkins_ecosystem][:server][:data_bag]       = 'servers'
default[:jenkins_ecosystem][:server][:data_bag_item]  = 'jenkins'

default[:jenkins_ecosystem][:storage_disk][:mount_path]         = node[:jenkins_ecosystem][:home]
default[:jenkins_ecosystem][:storage_disk][:iops]               = 1000
default[:jenkins_ecosystem][:storage_disk][:fstype]             = :btrfs
default[:jenkins_ecosystem][:storage_disk][:size]               = 250
default[:jenkins_ecosystem][:storage_disk][:device]             = '/dev/sdi'
default[:jenkins_ecosystem][:storage_disk][:volume_mount_point] = '/dev/xvdi'

default[:jenkins_ecosystem][:customization][:slave][:labels]      = ['ecosystem']
default[:jenkins_ecosystem][:customization][:slave][:executors]   = 5
default[:jenkins_ecosystem][:customization][:slave][:usage_mode]  = 'exclusive'

default[:jenkins_ecosystem][:vmware_tools][:url] = nil

default[:apache][:ssl_dir]              = '/etc/httpd/ssl'
default[:apache][:ssl_cert_file]        = "#{node[:apache][:ssl_dir]}/server.crt"
default[:apache][:ssl_cert_key_file]    = "#{node[:apache][:ssl_dir]}/server.key"
default[:apache][:ssl_cert_chain_file]  = "#{node[:apache][:ssl_dir]}/chain.crt"
default[:apache][:root_dir]             = '/var/www'

default[:jenkins_ecosystem][:git][:domain] = nil

default[:jenkins_ecosystem][:git][:version] = '2.8.1'
default[:jenkins_ecosystem][:git][:url] = 'https://github.com/git/git/archive/v2.8.1.tar.gz'
default[:jenkins_ecosystem][:git][:checksum] = 'e08503ecaf5d3ac10c40f22871c996a392256c8d038d16f52ebf974cba29ae42'

default[:jenkins_ecosystem][:jvm][:options][:xmx] = '256m'

#
# Cookbook Name:: jenkins_config
# Recipe:: default
#

if in_ec2?()
  aws = data_bag_item('aws', 'api')

  if node[:jenkins_ecosystem][:slave][:name].nil?

    elastic_ip = node[:jenkins_ecosystem][:ip]

    if elastic_ip.nil?
      server = data_bag_item(node[:jenkins_ecosystem][:server][:data_bag], node[:jenkins_ecosystem][:server][:data_bag_item])
      elastic_ip = server[:ip]
    end

    ec2_elastic_ip 'associate_jenkins_elastic_ip' do
      aws_access_key aws[:key]
      aws_secret_access_key aws[:secret]
      ip elastic_ip
      action :associate
    end
  end

  ec2_ebs_volume "#{node[:jenkins_ecosystem][:storage_disk][:mount_path]}-#{node[:jenkins_ecosystem][:storage_disk][:volume_mount_point]}-#{node[:jenkins_ecosystem][:storage_disk][:device]}" do
    aws_access_key aws[:key]
    aws_secret_access_key aws[:secret]
    volume_size node[:jenkins_ecosystem][:storage_disk][:size]
    volume_type "io1"
    volume_iops node[:jenkins_ecosystem][:storage_disk][:iops]
    volume_mount_path node[:jenkins_ecosystem][:storage_disk][:mount_path]
    volume_device node[:jenkins_ecosystem][:storage_disk][:device]
    volume_mount_point node[:jenkins_ecosystem][:storage_disk][:volume_mount_point]
    fstype node[:jenkins_ecosystem][:storage_disk][:fstype].to_s.to_sym
  end

end

include_recipe 'ec2'

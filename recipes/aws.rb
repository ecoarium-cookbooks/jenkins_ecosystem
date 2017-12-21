#
# Cookbook Name:: jenkins_config
# Recipe:: default
#

if in_ec2?()
  aws = data_bag_item("aws", "main")

  node.default[:jenkins_ecosystem][:storage_disk][:device] = '/dev/sdi'
  node.default[:jenkins_ecosystem][:storage_disk][:volume_mount_point] = '/dev/xvdi'

  ec2_ebs_volume "#{node[:jenkins_ecosystem][:storage_disk][:mount_path]}-#{node[:jenkins_ecosystem][:storage_disk][:volume_mount_point]}-#{node[:jenkins_ecosystem][:storage_disk][:device]}" do
    aws_access_key aws['aws_access_key_id']
    aws_secret_access_key aws['aws_secret_access_key']
    volume_size node[:jenkins_ecosystem][:storage_disk][:size]
    volume_type "io1"
    volume_iops node[:jenkins_ecosystem][:storage_disk][:iops]
    volume_mount_path node[:jenkins_ecosystem][:storage_disk][:mount_path]
    volume_device node[:jenkins_ecosystem][:storage_disk][:device]
    volume_mount_point node[:jenkins_ecosystem][:storage_disk][:volume_mount_point]
    fstype node[:nexus_ecosystem][:storage_disk][:fstype].to_s.to_sym
  end

end

include_recipe 'ec2'

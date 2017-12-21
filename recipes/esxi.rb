#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: aws
#

case node['platform']
when 'redhat', 'centos', 'fedora'
  if File.exist?('/etc/init/vmware-tools.conf')

    remote_file "#{Chef::Config[:file_cache_path]}/vmware-ovftool.tar.gz" do
      source node[:jenkins_ecosystem][:vmware_tools][:url]
      checksum lazy{ open("#{node[:jenkins_ecosystem][:vmware_tools][:url]}.sha1", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).string }
    end

    execute 'untar vmware ovftool' do
      cwd '/usr/lib'
      command "tar -zxvf #{Chef::Config[:file_cache_path]}/vmware-ovftool.tar.gz"
      creates '/usr/lib/vmware-ovftool/ovftool'
    end

    link '/usr/bin/ovftool' do
      to '/usr/lib/vmware-ovftool/ovftool'
    end

    if File.exist?(node[:jenkins_ecosystem][:storage_disk][:device])

      format_drive node[:jenkins_ecosystem][:storage_disk][:device] do
        type node[:jenkins_ecosystem][:storage_disk][:fstype].to_s.to_sym
        timeout node[:jenkins_ecosystem][:storage_disk][:size].to_s.to_i * 100
      end

      directory node[:jenkins_ecosystem][:storage_disk][:mount_path] do
        mode "0755"
        recursive true
        owner 'jenkins'
        group 'jenkins'
      end

      mount node[:jenkins_ecosystem][:storage_disk][:mount_path] do
        device node[:jenkins_ecosystem][:storage_disk][:device]
        options "rw noatime"
        fstype node[:jenkins_ecosystem][:storage_disk][:fstype].to_s
        action [ :enable, :mount ]
        not_if "cat /proc/mounts | grep #{node[:jenkins_ecosystem][:storage_disk][:mount_path]}"
      end

    else
      log "storage disk in ESXi guest does not exist: #{node[:jenkins_ecosystem][:storage_disk][:device]}" do
        level :warn
      end
    end
  end
when 'mac_os_x'

when 'windows'
  mount_point = "#{node[:jenkins_ecosystem][:storage_disk][:mount_path]}/Projects"
  if File.exist?('C:/Program Files/VMware/VMware Tools/vmtoolsd.exe')
    ovf_url = node[:jenkins_ecosystem][:vmware_tools][:url]

    windows_package 'VMware OVF Tool' do
      source ovf_url
      checksum lazy{ open("#{ovf_url}.sha1", {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).string }
    end

    check_script_file_path = '/tmp/check_disk_script'
    file check_script_file_path do
      content %^
list disk
exit
^
    end.run_action(:create)

    if Run.shell_true?("diskpart /s #{check_script_file_path} | findstr \"Disk #{node[:jenkins_ecosystem][:storage_disk][:device]}\"")
      format_drive node[:jenkins_ecosystem][:storage_disk][:device] do
        type node[:jenkins_ecosystem][:storage_disk][:fstype].to_s.to_sym
        timeout node[:jenkins_ecosystem][:storage_disk][:size].to_s.to_i * 100
      end

      directory mount_point do
        mode "0755"
        recursive true
        owner 'jenkins'
      end

      mount_script_file_path = '/tmp/mount_script'
      file mount_script_file_path do
        content %^
select volume 0
assign mount=#{mount_point}
exit
^
      end

      check_mount_script_file_path = '/tmp/check_mount_script'
      file check_mount_script_file_path do
        content %^
list volume
exit
^
      end
      corrected_path = mount_point.gsub('/', '\\')
      execute "diskpart /s #{mount_script_file_path}" do
        not_if "diskpart /s #{check_mount_script_file_path} | findstr #{corrected_path}"
      end
    end
  end
else
  Chef::Application.fatal!("this OS is not supported: #{node['platform']}")
end

#
# Cookbook Name:: jenkins_ecosystem
# Provider:: wait_until_up
#

action :wait do
  log_file_path = "/var/log/jenkins/jenkins.log"

  max_attempts = 80

  listening = false
  1.upto(max_attempts).each{ |attempt|
    Chef::Log.info("Waiting for jenkins to be available(watching netstat for listening on port #{node[:jenkins][:master][:port]}): attempt #{attempt} of #{max_attempts}")

    if system "netstat -tupln | awk '{print $4 \" \" $6 \" \" $7}' | egrep '#{node[:jenkins][:master][:port]}\s+LISTEN\s+[[:digit:]]+/java'"
      listening =true
      break
    end

    sleep 5
  }

  unless listening
    log_tail = `tail -n 20 #{log_file_path}`

    Chef::Application.fatal!("Jenkins never started. The log file may have useful information(#{log_file_path}):
#################### BEGIN TAIL LOG ####################

#{log_tail}

##################### END TAIL LOG #####################
")
  end

  responsive = false
  url = URI.parse("http://localhost:#{node[:jenkins][:master][:port]}/login")
  1.upto(max_attempts).each{ |attempt|
    Chef::Log.info("Waiting for jenkins to be available at #{url}: attempt #{attempt} of #{max_attempts}")

    repsonse = Chef::REST::RESTRequest.new(:GET, url, nil).call rescue nil

    if repsonse.kind_of?(Net::HTTPSuccess) or repsonse.kind_of?(Net::HTTPNotFound)
      responsive =true
      break
    end

    Chef::Log.debug "Jenkins not responding at #{url}: #{repsonse.inspect}"
    sleep 1
  }

  
  unless responsive

    log_tail = `tail -n 20 #{log_file_path}`

    Chef::Application.fatal!("Jenkins is not responsive at #{url}. The log file may have useful information(#{log_file_path}):
#################### BEGIN TAIL LOG ####################

#{log_tail}

##################### END TAIL LOG #####################
")
  end

  new_resource.updated_by_last_action(true)
end

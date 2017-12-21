#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: plugins
#

include_recipe "git"

restart_required = false

%w{
  github-oauth
  matrix-auth
  role-strategy
  ssh-agent
  credentials
  ssh-credentials
  token-macro
  git-client
  git
  greenballs
  groovy
  throttle-concurrents
  nested-view
  dashboard-view
  cloudbees-folder
  envinject
  email-ext
  preSCMbuildstep
  git-parameter
  cucumber-reports
  groovy-postbuild
  ansicolor
  htmlpublisher
  extensible-choice-parameter
  parameterized-trigger
  postbuild-task
  cobertura
  slack
  jacoco
  crap4j
  urltrigger
  ghprb
}.each do |plugin|
  plugin, version = plugin.split('=')
  jenkins_plugin plugin do
    version version if version
    notifies :create, "ruby_block[jenkins_restart_flag]", :immediately
  end
end

ruby_block "jenkins_restart_flag" do
  block do
    restart_required = true
  end
  action :nothing
end

jenkins_command 'restart' do
  only_if { restart_required }
end

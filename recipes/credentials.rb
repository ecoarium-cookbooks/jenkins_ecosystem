#
# Cookbook Name:: jenkins_ecosystem
# Recipe:: credentials
#

credentials = data_bag_item('credentials', 'jenkins')

node.run_state[:jenkins_private_key] = credentials[:private_key].join("\n")
#
# Author:: Ben Newton (<ben@sumologic.com>)
# Cookbook Name:: sumologic-collector
# Recipe:: Install Sumo Logic Collector
#
#
# Copyright 2013, Sumo Logic
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Install Steps:
# 1. Download collector installer
# 2. Do a quiet install
#
# Quiet install looks for /etc/sumo.conf file for automated activation
#
# Sumo Logic Help Links
# https://service.sumologic.com/ui/help/Default.htm#Unattended_Installation_from_a_Linux_Script_using_the_Collector_Management_API.htm
# https://service.sumologic.com/ui/help/Default.htm#Using_sumo.conf.htm
# https://service.sumologic.com/ui/help/Default.htm#JSON_Source_Configuration.htm
#

Chef::Log.info "Starting Installation."

  Chef::Log.info "Downloading Sumo Logic installer from #{node['sumologic']['downloadURL']}"
  
  remote_file "#{Chef::Config[:file_cache_path]}/#{node['sumologic']['installerName']}" do
    source node['sumologic']['downloadURL']
    mode '0644'
    not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/#{node['sumologic']['installerName']}") }
  end

case node['platform']
when 'redhat', 'centos', 'fedora', 'scientific'
  
  Chef::Log.info "Installing Sumo Logic"
  
  package "SumoCollector" do
    source "#{Chef::Config[:file_cache_path]}/#{node['sumologic']['installerName']}"
    provider Chef::Provider::Package::Rpm
  end
  
else
  unless ::File.exists?(node['sumologic']['installDir'])

    Chef::Log.info "Creating Sumo Logic directory at #{node['sumologic']['installDir']}"
  
    directory node['sumologic']['installDir']  do
      owner 'root'
      group 'root'
      mode '0755'
      recursive true
      action :create
    end
    
    Chef::Log.info "Installing Sumo Logic director at #{node['sumologic']['installDir']}"
  
    execute "Deploy Sumo Collector" do
      command "sh #{Chef::Config[:file_cache_path] + "/" + node['sumologic']['installerName']} -q -dir #{node['sumologic']['installDir']}"
      cwd node['sumologic']['installDir']
      timeout 3600
    end
  end
end

service "collector" do
  action [ :enable, :start ]
end
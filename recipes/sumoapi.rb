#
# Author:: Peter Bell (<bellpeterm+github@gmail.com>)
# Cookbook Name:: sumologic-collector
# Recipe:: sumoapi
# Purpose:: Adds, removes and updates SumoLogic Collector sources to match local configuration in /etc/sumo.json
#
#
# Copyright 2014, Peter Bell
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

# Update collector sources using the SumoLogic API
ruby_block "push changes to api" do
  block do

    credentials = {}
  
    if node[:sumologic][:credentials]
      creds = node[:sumologic][:credentials]
  
      if creds[:secret_file]
        secret = Chef::EncryptedDataBagItem.load_secret(creds[:secret_file]) 
        bag = Chef::EncryptedDataBagItem.load( creds[:bag_name], creds[:item_name], secret )
      else
        bag = data_bag_item( creds[:bag_name], creds[:item_name] )
      end
     
      [:accessID, :accessKey, :email, :password].each do |sym|
        credentials[sym] = bag[sym.to_s] # Chef::DataBagItem 10.28 doesn't work with symbols
      end
      
    else
      [:accessID,:accessKey,:email,:password].each do |sym|
        credentials[sym]  = node[:sumologic][sym]
      end 
    end
      
    user = credentials[:accessID] || credentials[:username]
    pass = credentials[:accessKey] || credentials[:password]

    apiconnection = Sumo.api_conn( user, pass )
    begin
      collector = Sumo.get_collector( apiconnection, node['fqdn'] )
      apisources = Sumo.get_sources( apiconnection, collector )
      localsources = Sumo.find_sources( "/etc/sumo.json" )
      
      updates = Sumo.sources_diff( localsources, apisources )
      
      Chef::Log.debug JSON.pretty_generate( updates )
      
      updates.each do |src|
        src.delete(:changedelement)
        case src.delete(:apiaction)
        when :create
          Sumo.create_source( apiconnection, collector, src )
        when :update
          Sumo.update_source( apiconnection, collector, src )
        when :delete
          Sumo.delete_source( apiconnection, collector, src )
        end
      end
    rescue Exception => e
      Chef::Log.error "\nUnable to configure sources via SumoLogic API: " + e.message
      Chef::Log.error "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
      FileUtils.touch "/etc/sumo.json", :mtime => Time.now - 86400
    end
  end
  if ::File.exists?( "/etc/sumo.json" ) and ::File.mtime( "/etc/sumo.json" ) <  Time.now - 86400
    action :run
  else
    action :nothing
  end
end
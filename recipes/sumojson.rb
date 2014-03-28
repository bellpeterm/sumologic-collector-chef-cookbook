#
# Author:: Ben Newton (<ben@sumologic.com>)
# Cookbook Name:: sumologic-collector
# Recipe:: Configure json for configuring sources
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

# This is a one time setup configuration file
#
# Sumo Logic Help Links
# https://service.sumologic.com/ui/help/Default.htm#Unattended_Installation_from_a_Linux_Script_using_the_Collector_Management_API.htm
# https://service.sumologic.com/ui/help/Default.htm#Using_sumo.conf.htm
# https://service.sumologic.com/ui/help/Default.htm#JSON_Source_Configuration.htm

# If there is a json_source specified via attributes use that one
# otherwise pick a default json template based on platform family.

accumulator "collect log sources for /etc/sumo.json" do
  target :template => "/etc/sumo.json"

  filter {|resource|
    resource.is_a? Chef::Resource::SumologicCollectorSource
  }

  transform {|sources|
    srcs = []
    sources.each do |source|
      sourcehash = {}
      case source.sourceType
      when "LocalFile"
        %w(sourceType pathExpression blacklist name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegex forceTimeZone defaultDateFormat filters).each do |attr|
          sourcehash[attr] = source.send(attr.to_sym) if source.respond_to?(attr.to_sym) and source.send(attr.to_sym) != nil
        end
      when "RemoteFile"
        %w(sourceType remoteHost remotePort remoteUser remotePassword keyPath keyPassword remotePath authMethod name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegex forceTimeZone defaultDateFormat filters).each do |attr|
          sourcehash[attr] = source.send(attr.to_sym) if source.respond_to?(attr.to_sym) and source.send(attr.to_sym) != nil
        end
      when "LocalWindowsEventLog"
        %w(sourceType logNames name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegex forceTimeZone defaultDateFormat filters).each do |attr|
          sourcehash[attr] = source.send(attr.to_sym) if source.respond_to?(attr.to_sym) and source.send(attr.to_sym) != nil
        end
      when "RemoteWindowsEventLog"
        %w(sourceType domain username password hosts name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegex forceTimeZone defaultDateFormat filters).each do |attr|
          sourcehash[attr] = source.send(attr.to_sym) if source.respond_to?(attr.to_sym) and source.send(attr.to_sym) != nil
        end
      when "Syslog"
        %w(sourceType protocol port name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegex forceTimeZone defaultDateFormat filters).each do |attr|
          sourcehash[attr] = source.send(attr.to_sym) if source.respond_to?(attr.to_sym) and source.send(attr.to_sym) != nil
        end
      when "Script"
        %w(sourceType commands file workingDir timeout script cronExpression name description category hostName timeZone automaticDateParsing multilineProcessingEnabled useAutolineMatching manualPrefixRegex forceTimeZone defaultDateFormat filters).each do |attr|
          sourcehash[attr] = source.send(attr.to_sym) if source.respond_to?(attr.to_sym) and source.send(attr.to_sym) != nil
        end
      end
        
      srcs.push(sourcehash)
    end
    srcs
  }
  variable_name :sources
  notifies :run, "ruby_block[push changes to api]", :immediately
end

template '/etc/sumo.json' do
  cookbook node['sumologic']['json_config_cookbook']
  source 'custom.json.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :nothing
end

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

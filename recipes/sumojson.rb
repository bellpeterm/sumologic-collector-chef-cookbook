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
  source 'sumo.json.erb'
  owner 'root'
  group 'root'
  mode 0644
  action :nothing
end

# Include sumoapi recipe to update the api based on the updated sumo.json
include_recipe 'sumologic-collector::sumoapi'
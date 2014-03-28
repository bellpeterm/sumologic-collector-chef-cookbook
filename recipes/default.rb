#
# Author:: Ben Newton (<ben@sumologic.com>)
# Contributors:: Peter Bell (<bellpeterm+github@gmail.com>)
# Cookbook Name:: sumologic-collector
# Recipe:: Install, Register, and Configure Collector
#
# Copyright 2013, Sumo Logic
#
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

#
# Sumo Logic Help Links
# https://service.sumologic.com/ui/help/Default.htm#Unattended_Installation_from_a_Linux_Script_using_the_Collector_Management_API.htm
# https://service.sumologic.com/ui/help/Default.htm#Using_sumo.conf.htm
# https://service.sumologic.com/ui/help/Default.htm#JSON_Source_Configuration.htm
#

include_recipe 'sumologic-collector::sumoconf' unless ::File.exists? "#{node['sumologic']['installDir']}/collector.status"

if node['sumologic']['sources'] == nil
  include_recipe 'sumologic-collector::sumojson'
else
  include_recipe 'sumologic-collector::sumocustomjson'
end

include_recipe 'sumologic-collector::install'

include_recipe 'sumologic-collector::cleanup' if ::File.exist? node['sumologic']['sumoConf']
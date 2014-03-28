#
# Author:: Ben Newton (<ben@sumologic.com>)
# Cookbook Name:: sumologic-collector
# Recipe:: Default Recipe Attributes
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

# default sumocollector attributes

# Collector Name if not set defaults to chef node name
default['sumologic']['name']      = nil

# Data Bag for Collector Credentials
default['sumologic']['credentials']['bag_name'] = 'sumo-creds'
default['sumologic']['credentials']['item_name'] = 'api-creds'

# Ephemeral node (collector config deleted after 2 days of no heartbeat - data is not deleted from Sumo Logic)
default['sumologic']['ephemeral'] = 'true'

# Default json.conf configuration templates cookbook
# Replace this with a custom cookbook name if you want to create
# your own custom sumo.json or template.
default['sumologic']['json_config_cookbook'] = 'sumologic-collector'

# Default sumo.conf configuration templates cookbook
# Replace this with a custom cookbook name if you want to create
# your own custom sumo.conf template.
default['sumologic']['conf_config_cookbook'] = 'sumologic-collector'

# Use this if you would like to manually specify the JSON for ALL of your sources.  You will not be able to use
# the sumologic-collector_source if you specify your sources this way.
default['sumologic']['sources'] = nil

# Default sumo.conf template.  Override this if you want to use a custom
# template name from a custom sumo.conf configuration cookbook.
default['sumologic']['conf_template'] = nil

#Platform Specific Attributes
case platform
    # Redhat derivatives use RPM; other linux use scripted install
    when 'redhat', 'centos', 'scientific', 'fedora'
      # Installer Name
      default['sumologic']['installerName'] = node['kernel']['machine'] =~ /^i[36']86$/ ? 'SumoCollector32.rpm' : 'SumoCollector64.rpm'

      # Sumo.conf path
      default['sumologic']['sumoConf'] = "/etc/sumo.conf"
      
      # Install Path
      default['sumologic']['installDir']     = '/opt/SumoCollector'

      # Download Path - Either 32bit or 64bit according to the architecture
      default['sumologic']['downloadURL'] = node['kernel']['machine'] =~ /^i[36']86$/ ? 'https://collectors.sumologic.com/rest/download/rpm/32' : 'https://collectors.sumologic.com/rest/download/rpm/64'

    when 'suse', 'amazon', 'oracle', 'debian', 'ubuntu'
      # Install Path
      default['sumologic']['installDir']     = '/opt/SumoCollector'

      # Install Command
      default['sumologic']['installerCmd'] = "sh #{default['sumologic']['installerName']} -q -dir #{default['sumologic']['installDir']}"

      # Installer Name
      default['sumologic']['installerName'] = node['kernel']['machine'] =~ /^i[36']86$/ ? 'SumoCollector_linux32.sh' : 'SumoCollector_linux64.sh'

      # Sumo.conf path
      default['sumologic']['sumoConf'] = "/etc/sumo.conf"
      
      # Download Path - Either 32bit or 64bit according to the architecture
      default['sumologic']['downloadURL'] = node['kernel']['machine'] =~ /^i[36']86$/ ? 'https://collectors.sumologic.com/rest/download/linux/32' : 'https://collectors.sumologic.com/rest/download/linux/64'

    else
      # Just have empty install commands for now as a placeholder
      # Install Path
      default['sumologic']['installDir']     = '/opt/SumoCollector'

      # Installer Name - Either 32bit or 64bit according to the architecture
      default['sumologic']['installerName'] = ''

      # Install Command
      default['sumologic']['installerCmd'] = ''

      # Sumo.conf path
      default['sumologic']['sumoConf'] = ''

      # Download Path
      default['sumologic']['downloadURL'] = ''
      
end

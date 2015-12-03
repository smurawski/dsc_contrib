#
# Cookbook Name:: dsc_contrib
# Recipe:: dsc_resource_lcm_setup
#
# Copyright 2015 2015, Chef Software, Inc.
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


log_message = "Configuring the LCM Refresh Mode to Disabled." \
              "  For WMF 5 builds before 10586, the LCM must be disabled" \
              " in order for dsc_resource to be used."

log "notify_lcm_change" do
  message log_message
  action :nothing
end

powershell_script "Configure LCM for dsc_resource" do
  code <<-EOH
    [DscLocalConfigurationManager()]
    Configuration ConfigLCM
    {
        Node "localhost"
        {
            Settings
            {
                ConfigurationMode = "ApplyOnly"
                RebootNodeIfNeeded = $false
                RefreshMode = 'Disabled'
            }
        }
    }
    ConfigLCM -OutputPath "#{Chef::Config[:file_cache_path]}\\DSC_LCM"
    Set-DscLocalConfigurationManager -Path "#{Chef::Config[:file_cache_path]}\\DSC_LCM"
  EOH
  only_if <<-EOH
    $psversiontable.psversion.major -ge 5 -and
    $psversiontable.psversion.build -lt 10586 -and
    (Get-DscLocalConfigurationManager).RefreshMode -notlike "Disabled"
  EOH
  notifies :write, 'log[notify_lcm_change]', :immediately
end 

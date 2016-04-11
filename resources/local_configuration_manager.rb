#
# Author:: Steven Murawski (<smurawski@chef.io>)
# Coypright:: Coypright (c) 2016 Chef Software, Inc.
# License:: Apache License, Version 2.0
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

resource_name :local_configuration_manager

provides :local_configuration_manager, platform: 'windows'

property :action_after_reboot, kind_of: String, default: 'StopConfiguration'
property :certificate_id, kind_of: String
property :configuration_mode, kind_of: String, default: 'ApplyOnly'
property :reboot_node_if_needed, kind_of: [TrueClass, FalseClass], default: false
property :debug_mode, kind_of: String, default: 'NONE'

def version(version_string)
  ::Gem::Version.new(version_string)
end

def reboot_node_if_needed_ps(new_resource)
  new_resource.reboot_node_if_needed ? '$true' : '$false'
end

def certificate_id_ps(new_resource)
  new_resource.certificate_id.nil? ? '$null' : "'#{new_resource.certificate_id}'"
end

action :enable do
  return unless node[:languages] && node[:languages][:powershell]
  powershell_version = version(node[:languages][:powershell][:version])
  return if powershell_version < version('4.0')

  common_config_block = <<-EOH
ActionAfterReboot = '#{new_resource.action_after_reboot}'
CertificateID = #{certificate_id_ps(new_resource)}
ConfigurationMode = '#{new_resource.configuration_mode}'
RebootNodeIfNeeded = #{reboot_node_if_needed_ps(new_resource)}
DebugMode = '#{new_resource.debug_mode}'
EOH
  common_execute_script = <<-EOH
mkdir $env:temp/LCM -force
LCM -outputpath $env:temp/LCM
set-dsclocalconfigurationmanager -path $env:temp/LCM
EOH
  common_not_if = <<-EOH
$LCM = get-dsclocalconfigurationmanager
($lcm.actionafterreboot -eq '#{new_resource.action_after_reboot}') -and
($lcm.certificateid -eq #{certificate_id_ps(new_resource)}) -and
($lcm.configurationmode) -eq '#{new_resource.configuration_mode}' -and
($lcm.rebootnodeifneeded -eq #{reboot_node_if_needed_ps(new_resource)}) -and
($lcm.debugmode) -eq '#{new_resource.debug_mode}'
EOH
  if powershell_version >= version('5.0')
    powershell_script 'Configure the LCM' do
      code <<-EOH
        [DSCLocalConfigurationManager()]
        configuration 'LCM' {
          Settings {
            #{common_config_block}
          }
        }
        #{common_execute_script}
      EOH
      not_if common_not_if
    end
  else
    powershell_script 'Configure the LCM' do
      code <<-EOH
        configuration 'LCM' {
          LocalConfigurationManager {
            #{common_config_block}
          }
        }
        #{common_execute_script}
      EOH
      not_if common_not_if
    end
  end
end

#
# Author:: Steven Murawski (<smurawski@chef.io>)
# Coypright:: Coypright (c) 2015 Chef Software, Inc.
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

if Gem::Version.new(Chef::VERSION) >= Gem::Version.new('12.4') &&
   Gem::Version.new(Chef::VERSION) < Gem::Version.new('12.6')

  class Chef
    class Platform
      class << self

        def supports_dsc_invoke_resource?(node)
          supports_dsc?(node) &&
            supported_powershell_version?(node, "5.0.10018.0")
        end

        def supports_refresh_mode_enabled?(node)
          supported_powershell_version?(node, "5.0.10586.0")
        end

        def dsc_refresh_mode_disabled?(node)
          require 'chef/util/powershell/cmdlet'
          cmdlet = Chef::Util::Powershell::Cmdlet.new(node, "Get-DscLocalConfigurationManager", :object)
          metadata = cmdlet.run!.return_value
          metadata['RefreshMode'] == 'Disabled'
        end

        def supported_powershell_version?(node, version_string)
          return false unless node[:languages] && node[:languages][:powershell]
          require 'rubygems'
          Gem::Version.new(node[:languages][:powershell][:version]) >=
            Gem::Version.new(version_string)
        end

      end
    end
  end

end

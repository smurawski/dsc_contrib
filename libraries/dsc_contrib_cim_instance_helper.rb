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

require 'chef/mixin/powershell_type_coercions'

module DscContrib
  module CimInstanceHelper
    def cim_instance(name, *properties)
      DscContrib::CimConverter.new(name, properties, false)
    end
    def cim_instance_array(name, *properties)
      DscContrib::CimConverter.new(name, properties, true)
    end
    def cim_instance_array_helper(instances)
      DscContrib::CimInstanceArray.new(instances)
    end
  end

  class CimConverter
    include Chef::Mixin::PowershellTypeCoercions

    def initialize(name, properties, is_array)
      @name = name
      @properties = (properties.flatten)[0]
      @is_array = is_array
    end

    def cim_instance_array_script
      "([Microsoft.Management.Infrastructure.CimInstance[]](#{cim_instance_script}))"
    end

    def cim_instance_script
      "new-ciminstance -classname #{@name} -property #{translate_type(@properties)} -clientonly"
    end

    def to_psobject
      return cim_instance_array_script if @is_array
      cim_instance_script
    end

    alias to_s to_psobject
    alias to_text to_psobject
  end

  class CimInstanceArray
    include Chef::Mixin::PowershellTypeCoercions

    def initialize(instances)
      @instances = instances
    end

    def cim_instance_script
      "([Microsoft.Management.Infrastructure.CimInstance[]]((#{@instances.join('),(')})))"
    end

    def to_psobject
      cim_instance_script
    end

    alias to_s to_psobject
    alias to_text to_psobject
  end
end

Chef::Resource::DscResource.send(:include, DscContrib::CimInstanceHelper)

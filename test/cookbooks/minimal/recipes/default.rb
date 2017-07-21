#

unless Chef::Platform.supports_dsc_invoke_resource?(node)
  include_recipe 'powershell::powershell5'

  reboot 'Now' do
    action :reboot_now
    guard_interpreter :powershell_script
    not_if '$psversiontable.psversion.major -ge 5'
    delay_mins 1
  end
end

include_recipe 'dsc_contrib::dsc_resource_lcm_setup'

dsc_resource 'Install IIS' do
  resource :windowsfeature
  property :name, 'web-server'
  property :ensure, 'Present'
  reboot_action :request_reboot
end

# If installing didn't require a reboot,
# then removing it immediately after will.
dsc_resource 'Remove IIS' do
  resource :windowsfeature
  property :name, 'web-server'
  property :ensure, 'Absent'
  reboot_action :request_reboot
end

reboot 'Cancel reboot' do
  action :cancel
  reason 'I do not really want to reboot now'
end

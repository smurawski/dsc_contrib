unless Chef::Platform.supports_dsc_invoke_resource?(node)
  include_recipe 'powershell::powershell5'

  reboot 'Now' do
    action :reboot_now
    guard_interpreter :powershell_script
    not_if '$psversiontable.psversion.major -ge 5'
    delay_mins 1
  end
end
powershell_script "deps" do
  code <<-EOH
    install-packageprovider nuget -force -forcebootstrap
    install-module xwebadministration -force
  EOH
end

dsc_resource 'Install IIS' do
  resource :windowsfeature
  property :name, 'web-server'
  property :ensure, 'Present'
  reboot_action :request_reboot
end

dsc_resource 'Test BindingIndfo' do
  resource :xWebsite
  property :ensure, 'Present'
  property :name, 'test'
  property :state, 'started'
  property :physicalpath, 'c:\inetpub\wwwroot'
  property :bindinginfo , cim_instance_array(
    'MSFT_xWebBindingInformation',
    Protocol: 'http',
    Port: 80,
    Hostname: 'localhost'
    )
  #property :psdscrunascredential, ps_credential('vagrant', 'vagrant')
end

powershell_script "deps" do
  code <<-EOH
    install-packageprovider nuget -force -forcebootstrap
    install-module xwebadministration -force
  EOH
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

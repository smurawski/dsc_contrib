

# dsc_contrib

This cookbook exists to augment the integration of Chef and Windows PowerShell Desired State Configuration (DSC).

## Back-compat for reboot_action

Chef 12.6 introduces a new property to the dsc_resource resource. When the API that is used by dsc_resource to enforce a desired state (the `set` method), the API returns a boolean noting if the DSC resource requested a reboot to continue.

This request is separate from any other mechanism that is used by components of the Windows operating system to indicate a reboot is needed (but may be in conjunction with one or more of them).

When this API returns that a reboot is requested, the `reboot_action` property is used to dynamically create a [reboot resource](https://docs.chef.io/resource_reboot.html).  Valid arguments for `reboot_action` (at this time) are `:reboot_now` and `:request_reboot`.  These are the same actions as the reboot resource takes.

This allows you to control reboot requests from DSC in a Chef-friendly fashion.

This cookbook adds `reboot_action` to Chef 12.4.x and 12.5.x.

## Helpers

### cim_instance and cim_instance_array
This cookbook adds `cim_instance` and `cim_instance_array` helpers to the `dsc_resource` resource.  This helps support embedded CIM instances for DSC resources that require them.

Both `cim_instance` and `cim_instance_array` have the first parameter as the cim instance type and the remaining parameter make up a hash table of the properties to be converted into a CIM instance.

The difference between the helper methods is some resources expect a single CIM instance and some expect an array.  PowerShell will not cast it a single instance into an array, so we have to specify that.

### ps_module_spec
The `ps_module_spec` helper allows you to identify which side by side resource to use when multiple exist on a system.

No version specified: 

```
dsc_resource 'blah' do
  module_version ps_module_spec("SomeModule")
  ...
```

Version specified:

```
dsc_resource 'blah' do
  module_version ps_module_spec("SomeModule", "1.2.4.5")
  ...
```

## Resources

### `local_configuration_manager`

This resource will configure some of the basic LCM settings for use with Chef.  There is currenlty only one action - `:enable`

* `action_after_reboot` - defaults to 'StopConfiguration'
* `certificate_id' - default to $null
* `configuration_mode` - defaults to 'ApplyOnly'
* `reboot_node_if_needed` - defaults to $false
* `debug_mode` - defaults to 'NONE'

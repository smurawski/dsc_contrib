# dsc_contrib

This cookbook exists to augment the integration of Chef and Windows PowerShell Desired State Configuration (DSC).

## Back-compat for reboot_action

Chef 12.6 introduces a new property to the dsc_resource resource. When the API that is used by dsc_resource to enforce a desired state (the `set` method), the API returns a boolean noting if the DSC resource requested a reboot to continue.

This request is separate from any other mechanism that is used by components of the Windows operating system to indicate a reboot is needed (but may be in conjunction with one or more of them).

When this API returns that a reboot is requested, the `reboot_action` property is used to dynamically create a [reboot resource](https://docs.chef.io/resource_reboot.html).  Valid arguments for `reboot_action` (at this time) are `:reboot_now` and `:request_reboot`.  These are the same actions as the reboot resource takes.

This allows you to control reboot requests from DSC in a Chef-friendly fashion.

This cookbook adds `reboot_action` to Chef 12.4.x and 12.5.x.

## Recipes

### `dsc_resource_lcm_setup`

This recipe will set the DSC Local Configuration Manager (LCM) to disabled for the PowerShell 5 preview builds that require it to use `dsc_resource`
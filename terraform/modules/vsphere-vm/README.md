# vSphere VM

The module deploys a VM in a vSphere environment. The virtual machine can be customized using a mixing of cloud-init configurations and Ansible playbooks.

The module has been tested with Ubuntu 22.04.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| fqdn | Fully qualified domain name of the VM | `string` | n/a | yes |
| vm\_authorized\_key | Public key authorized to ssh into the VM | `string` | n/a | yes |
| vsphere | vSphere related references to deploy the VM | <pre>object({<br>    resource_pool_id = string<br>    datastore_id = string<br>    network_id = string<br>    template_id = string<br>  })</pre> | n/a | yes |
| ansible\_galaxy\_actions | Additional Ansible galaxy actions to perform during cloud-init | `list(list(string))` | `[]` | no |
| ansible\_playbook | base64 encoded playbook | `string` | `null` | no |
| cloud\_init | Custom cloud-init to use instead of the default provided by the module. If a custom value is provided, most of the configuration set in the variable will not be applied (including ssh keys and the Ansible playbook). It must be a base64 encoded string | `string` | `null` | no |
| cloud\_init\_write\_files | Additional files to push using cloud-init. The key is the destination path in the VM and the value is the content in base64 encodeding. | `map(string)` | `{}` | no |
| root\_password | Password to assign to the root user. If no value is provided a random password will be generated. | `string` | `null` | no |
| vm\_specs | n/a | <pre>object({<br>    cpu = optional(number, 2)<br>    memory = optional(number, 4096)<br>    disk_size = optional(number, 50)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| instance\_ip | n/a |
<!-- END_TF_DOCS -->
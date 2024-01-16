# vSphere VM

The module deploys a VM in a vSphere environment. The virtual machine can be customized using a mixing of cloud-init configurations and Ansible playbooks.

The module has been tested with Ubuntu 22.04.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | Fully qualified domain name of the VM | `string` | n/a | yes |
| <a name="input_vm_authorized_key"></a> [vm\_authorized\_key](#input\_vm\_authorized\_key) | Public key authorized to ssh into the VM | `string` | n/a | yes |
| <a name="input_vsphere"></a> [vsphere](#input\_vsphere) | vSphere related references to deploy the VM | <pre>object({<br>    resource_pool_id = string<br>    datastore_id = string<br>    network_id = string<br>    template_id = string<br>  })</pre> | n/a | yes |
| <a name="input_ansible_galaxy_actions"></a> [ansible\_galaxy\_actions](#input\_ansible\_galaxy\_actions) | Additional Ansible galaxy actions to perform during cloud-init | `list(list(string))` | `[]` | no |
| <a name="input_ansible_playbook"></a> [ansible\_playbook](#input\_ansible\_playbook) | base64 encoded playbook | `string` | `null` | no |
| <a name="input_cloud_init"></a> [cloud\_init](#input\_cloud\_init) | Custom cloud-init to use instead of the default provided by the module. If a custom value is provided, most of the configuration set in the variable will not be applied (including ssh keys and the Ansible playbook). It must be a base64 encoded string | `string` | `null` | no |
| <a name="input_cloud_init_write_files"></a> [cloud\_init\_write\_files](#input\_cloud\_init\_write\_files) | Additional files to push using cloud-init. The key is the destination path in the VM and the value is the content in base64 encodeding. | `map(string)` | `{}` | no |
| <a name="input_root_password"></a> [root\_password](#input\_root\_password) | Password to assign to the root user. If no value is provided a random password will be generated. | `string` | `null` | no |
| <a name="input_vm_specs"></a> [vm\_specs](#input\_vm\_specs) | n/a | <pre>object({<br>    cpu = optional(number, 2)<br>    memory = optional(number, 4096)<br>    disk_size = optional(number, 50)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_ip"></a> [instance\_ip](#output\_instance\_ip) | n/a |
<!-- END_TF_DOCS -->
# Harbor standalone

The module deploys Harbor registry in a VM in a vSphere environment.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_vm_authorized_key"></a> [vm\_authorized\_key](#input\_vm\_authorized\_key) | Public key authorized to ssh into the VM | `string` | n/a | yes |
| <a name="input_vsphere"></a> [vsphere](#input\_vsphere) | vSphere related references to deploy the VM | <pre>object({<br>    resource_pool_id = string<br>    datastore_id = string<br>    network_id = string<br>    template_id = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_harbor_instance_ip"></a> [harbor\_instance\_ip](#output\_harbor\_instance\_ip) | n/a |
<!-- END_TF_DOCS -->
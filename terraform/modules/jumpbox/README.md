# Jumpbox

The module deploys a jumpbox machine in a vSphere environment.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | n/a | `string` | n/a | yes |
| vm\_authorized\_key | Public key authorized to ssh into the VM | `string` | n/a | yes |
| vsphere | vSphere related references to deploy the VM | <pre>object({<br>    resource_pool_id = string<br>    datastore_id = string<br>    network_id = string<br>    template_id = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| jumpbox\_instance\_ip | n/a |
<!-- END_TF_DOCS -->
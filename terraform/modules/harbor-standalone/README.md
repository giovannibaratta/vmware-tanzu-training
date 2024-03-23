# Harbor standalone

The module deploys Harbor registry in a VM in a vSphere environment.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| fqdn | Fully qualified domain name of the VM | `string` | n/a | yes |
| vm\_authorized\_key | Public key authorized to ssh into the VM | `string` | n/a | yes |
| vsphere | vSphere related references to deploy the VM | <pre>object({<br>    resource_pool_id = string<br>    datastore_id = string<br>    network_id = string<br>    template_id = string<br>  })</pre> | n/a | yes |
| tls | TLS configuration to use. Private key and certificate must be base64 encoded | <pre>object({<br>    private_key = string<br>    certificate = string<br>    ca_chain = optional(string, null)<br>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| harbor\_admin\_password | n/a |
| instance\_ip | n/a |
<!-- END_TF_DOCS -->
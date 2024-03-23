# 01-tkgs-nsx

The stage deploys external resources that can be used to provide additional services on top of TKGs. The stage assumes that TKGs and NSX are already installed.

The available services are:
* Harbor
* MinIO
* Keycloak

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | n/a | `string` | n/a | yes |
| vcenter\_data | n/a | <pre>object({<br>    datacenter_name = string<br>    cluster_name = string<br>    datastore_name = string<br>    mgmt_segment_name = string<br>  })</pre> | n/a | yes |
| vm\_authorized\_key | n/a | `string` | n/a | yes |
| vsphere\_password | n/a | `string` | n/a | yes |
| vsphere\_server | n/a | `string` | n/a | yes |
| vsphere\_user | n/a | `string` | `"administrator@vsphere.local"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ips | n/a |
<!-- END_TF_DOCS -->
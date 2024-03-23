# Deploy TKGs clusters

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ca\_certificate | Certificate in PEM format of the CA | `string` | n/a | yes |
| kubeconfig\_path | Path to the kubeconfig to use | `string` | `null` | no |
| output\_dir | n/a | `string` | `null` | no |
| sensitive\_output\_dir | n/a | `string` | `null` | no |
| supervisor\_context\_name | Name of the supervisor context in .kube/config | `string` | `null` | no |
| tkgs\_clusters | n/a | <pre>list(object({<br>    control_plane_replicas = optional(number, 1)<br>    worker_node_replicas   = optional(number, 3)<br>    namespace              = string<br>    name                   = string<br>    tkr                    = string<br>    storage_class          = string<br>    vm_class               = string<br>  }))</pre> | `[]` | no |
<!-- END_TF_DOCS -->
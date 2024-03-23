# TMC Flux TKGs cluster

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_name | n/a | `string` | n/a | yes |
| cluster\_namespace | n/a | `string` | n/a | yes |
| cluster\_overlay\_path | Path in the Git repo that contains the kustomization.yaml file for the cluster | `string` | n/a | yes |
| git\_repo\_url | The URL should not include https and there shouldn't be any trailing / | `string` | n/a | yes |
| managed\_by | Name of the supervisor cluster that will manage the cluster | `string` | n/a | yes |
| storage\_class\_name | n/a | `string` | n/a | yes |
| vm\_class | n/a | `string` | n/a | yes |
| cluster\_additional\_trusted\_cas | n/a | `string` | `null` | no |
| cluster\_group | n/a | `string` | `null` | no |
| control\_plane\_replicas | n/a | `number` | `1` | no |
| git\_branch | The URL should not include https and there shouldn't be any trailing / | `string` | `"main"` | no |
| git\_repo\_credentials | n/a | <pre>object({<br>    type = string<br>    ssh = optional(object({<br>      identity    = string<br>      known_hosts = string<br>    }))<br>    user_pass = optional(object({<br>      username = string<br>      password = string<br>    }))<br>  })</pre> | `null` | no |
| worker\_nodes\_replicas | n/a | `number` | `3` | no |
<!-- END_TF_DOCS -->
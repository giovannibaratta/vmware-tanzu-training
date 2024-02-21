<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| clusters\_additional\_trusted\_cas | Additional CA in PEM encoding. The CAs can be concatenated | `string` | n/a | yes |
| git\_repo\_url | The URL should not include https and there shouldn't be any trailing / | `string` | n/a | yes |
| supervisor\_context\_name | Name of the supervisor context in .kube/config | `string` | n/a | yes |
| tmc | Attributes used to configure the TMC provider | <pre>object({<br>    endpoint    = string<br>    oidc_issuer = string<br>    username    = string<br>    password    = string<br>    ca_cert     = string<br>  })</pre> | n/a | yes |
| git\_repo\_credentials | n/a | <pre>object({<br>    type = string<br>    ssh = optional(object({<br>      identity    = string<br>      known_hosts = string<br>    }))<br>    user_pass = optional(object({<br>      username = string<br>      password = string<br>    }))<br>  })</pre> | `null` | no |
| gitops\_repo\_root\_folder | path of folder containing the root kustomization.yaml | `string` | `""` | no |
<!-- END_TF_DOCS -->
# Services

## Apply

```sh
terraform apply -var-file=terraform.tfvars -var-file=../../outputs/01-tkgs-nsx/h2o-2-23532/output.json -var-file=../../outputs/01-tkgs-nsx/h2o-2-23532/sensitive-output.json
```
<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain | n/a | `string` | n/a | yes |
| idp\_provider | n/a | <pre>object({<br>    url = string<br>    username = string<br>    password = string<br>    root_ca = string<br>  })</pre> | `null` | no |
| output\_dir | n/a | `string` | `null` | no |
| registry\_projects | List of projects that must be created in the registry | `set(string)` | `[]` | no |
| registry\_provider | n/a | <pre>object({<br>    url = string<br>    username = string<br>    password = string<br>  })</pre> | `null` | no |
| sensitive\_output\_dir | n/a | `string` | `null` | no |
<!-- END_TF_DOCS -->
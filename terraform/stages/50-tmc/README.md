# TMC

> This Terraform code has been tested with TMC SM v1.2

## Prerequisites

- A supervisor cluster registered in TMC

## Plan/Apply

The terraform code needs to create a secret in the supervisor cluster, hence we must be logged into the supervisor before running `terraform plan/apply`

```sh
terraform apply -var-file=terraform.tfvars -parallelism=1
```

## Troubleshooting

**<i>During a plan/apply Terraform hangs while processing resources managed by a Kubernetes provider</i>**

It is possible that the `tmc` CLI is not authenticated anymore. Try to login again to the TMC instance using the CLI.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| age\_secret\_key | n/a | `string` | n/a | yes |
| ca\_certificate | n/a | `string` | n/a | yes |
| domain | n/a | `string` | n/a | yes |
| git\_repo\_url | The URL should not include https and there shouldn't be any trailing / | `string` | n/a | yes |
| supervisor\_context\_name | Name of the supervisor context in .kube/config | `string` | n/a | yes |
| tmc\_admin\_user | n/a | <pre>object({<br>    username = string<br>    password = string<br>  })</pre> | n/a | yes |
| clusters\_additional\_trusted\_cas | Additional CA in PEM encoding. The CAs can be concatenated | `string` | `null` | no |
| git\_repo\_credentials | n/a | <pre>object({<br>    type = string<br>    ssh = optional(object({<br>      identity    = string<br>      known_hosts = string<br>    }))<br>    user_pass = optional(object({<br>      username = string<br>      password = string<br>    }))<br>  })</pre> | `null` | no |
| gitops\_repo\_cluster\_root\_folder | path of folder containing the root kustomization.yaml | `string` | `""` | no |
| supervisor\_name | n/a | `string` | `"Name of the supervisor registered in TMC"` | no |
| tap\_branch | n/a | `string` | `"main"` | no |
<!-- END_TF_DOCS -->

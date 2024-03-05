# TMC

> This Terraform code has been tested with TMC SM v1.1

## Prerequisites

In order to create resources on clusters that are deployed by this code, we need to use the `exec` option of the `Kubernetes` Terraform provider. The `exec` option will generate an authentication token using the TMC CLI. Unfortunately, the newer version of the plugin `mission-control (or tmc)` shipped with the Tanzu doesn't seem to work, therefore we have to rely on the old CLI.

1. Download the CLI from TMC UI (Automation Center -> TMC CLI)
1. Authenticate to TMC `tmc system context create --self-managed -e <endpoint>:443 -n <content-name> --basic-auth`

## Plan/Apply

The terraform code needs to create a secret in the supervisor cluster, hence we must be logged into the supervisor before running `terraform plan/apply`

## Troubleshooting

**<i>During a plan/apply Terraform hangs while processing resources managed by a Kubernetes provider</i>**

It is possible that the `tmc` CLI is not authenticated anymore. Try to login again to the TMC instance using the CLI.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| age\_secret\_key | n/a | `string` | n/a | yes |
| clusters\_additional\_trusted\_cas | Additional CA in PEM encoding. The CAs can be concatenated | `string` | n/a | yes |
| git\_repo\_url | The URL should not include https and there shouldn't be any trailing / | `string` | n/a | yes |
| supervisor\_context\_name | Name of the supervisor context in .kube/config | `string` | n/a | yes |
| tmc | Attributes used to configure the TMC provider | <pre>object({<br>    endpoint    = string<br>    oidc_issuer = string<br>    username    = string<br>    password    = string<br>    ca_cert     = string<br>  })</pre> | n/a | yes |
| git\_repo\_credentials | n/a | <pre>object({<br>    type = string<br>    ssh = optional(object({<br>      identity    = string<br>      known_hosts = string<br>    }))<br>    user_pass = optional(object({<br>      username = string<br>      password = string<br>    }))<br>  })</pre> | `null` | no |
| gitops\_repo\_cluster\_root\_folder | path of folder containing the root kustomization.yaml | `string` | `""` | no |
<!-- END_TF_DOCS -->

# Vault

This directory contains the Terraform code to configure a Vault cluster.

> No data (e.g. secrets), except for the one that are strictly required, should be created using this code because all the information will also be stored in the Terraform state file.

## Prerequisites

* A Vault cluster
* A valid token to authenticate to the cluster
* (optional) a OIDC provider if the relative auth backend must be enabled
* (optional) a Kubernetes cluster if the relative auth backend must be enabled

## Usage

1. Replace the value in [terraform.tfvars](./terraform.tfvars)
1. Create (or replace the value in) [terraform-secrets.tfvars]
1. (optional) Configure the Terraform backend
1. `terraform init/plan/apply -var-file=terraform.tfvars -var-file=terraform-secrets.tfvars`

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| token | Vault token | `string` | n/a | yes |
| vault\_address | Vault server address | `string` | n/a | yes |
| enable\_kubernetes\_auth | Configure Kubernetes authentication in Vault. | `bool` | `false` | no |
| enable\_oidc\_auth | Configure OIDC authentication in Vault. | `bool` | `false` | no |
| kubernetes\_auth\_config | Must be set if enable\_kubernetes\_auth is true. Host is the Kubernetes server that will validate the JWT token received by the Agent injector. | <pre>object({<br>    host = string<br>    ca = string<br>  })</pre> | `null` | no |
| oidc\_config | Parameters to configure OIDC auth. Required if enable\_oidc\_auth is true | <pre>object({<br>    client_id     = string<br>    discovery_url = string<br>    user_claim    = string<br>    groups_claim  = string<br>    scopes        = set(string)<br>  })</pre> | `null` | no |
| oidc\_config\_sensitive | Parameters to configure OIDC auth. Required if enable\_oidc\_auth is true | <pre>object({<br>    client_secret = string<br>  })</pre> | `null` | no |
<!-- END_TF_DOCS -->
# NSX-T

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
| <a name="input_nsxt_config"></a> [nsxt\_config](#input\_nsxt\_config) | Information to connect to the NSX manager | <pre>object({<br>    host                 = string<br>    username             = string<br>    allow_unverified_ssl = bool<br>  })</pre> | n/a | yes |
| <a name="input_nsxt_config_sensitive"></a> [nsxt\_config\_sensitive](#input\_nsxt\_config\_sensitive) | Information to connect to the NSX manager | <pre>object({<br>    password = string<br>  })</pre> | n/a | yes |
<!-- END_TF_DOCS -->
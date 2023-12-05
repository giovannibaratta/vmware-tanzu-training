<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oidc_config"></a> [oidc\_config](#input\_oidc\_config) | n/a | <pre>object({<br>    client_id = string<br>    discovery_url = string<br>    user_claim = string<br>    groups_claim = string<br>    scopes = set(string)<br>    redirect_uri = string<br>  })</pre> | n/a | yes |
| <a name="input_oidc_config_sensitive"></a> [oidc\_config\_sensitive](#input\_oidc\_config\_sensitive) | n/a | <pre>object({<br>    client_secret = string<br>  })</pre> | n/a | yes |
| <a name="input_groups_mapping"></a> [groups\_mapping](#input\_groups\_mapping) | Map OIDC groups to groups managed by Vault. The key is the OIDC group name and the value is the Vault group id | `map(string)` | `{}` | no |
<!-- END_TF_DOCS -->
# vault-oidc

The module is responsible for configuring an auth method of type [OIDC](https://developer.hashicorp.com/vault/docs/auth/jwt#jwt-authentication).

A default role is created as part of the setup, the role will be used for users who don't specify a specific role during the login.

<!-- BEGIN_TF_DOCS -->
<!-- This section will be overridden by terraform-docs. Do not change it.-->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| oidc\_config | n/a | <pre>object({<br>    client_id = string<br>    discovery_url = string<br>    user_claim = string<br>    groups_claim = string<br>    scopes = set(string)<br>    redirect_uri = string<br>  })</pre> | n/a | yes |
| oidc\_config\_sensitive | n/a | <pre>object({<br>    client_secret = string<br>  })</pre> | n/a | yes |
| groups\_mapping | Map OIDC groups to groups managed by Vault. The key is the OIDC group name and the value is the Vault group id | `map(string)` | `{}` | no |
<!-- END_TF_DOCS -->
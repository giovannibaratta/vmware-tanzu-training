resource "vault_jwt_auth_backend" "oidc" {
  description        = "OIDC backend"
  path               = "oidc"
  type               = "oidc"
  oidc_discovery_url = var.oidc_config.discovery_url
  oidc_client_id     = var.oidc_config.client_id
  oidc_client_secret = var.oidc_config_sensitive.client_secret
  default_role       = "default"
}

resource "vault_jwt_auth_backend_role" "default" {
  backend        = vault_jwt_auth_backend.oidc.path
  role_name      = "default"
  token_policies = ["default"]

  # Attribute provided by the OIDC provider that can be used to univocally identify the user.
  user_claim            = var.oidc_config.user_claim
  # Attribute provided by the OIDC provider that should be used to extract the list of groups
  # assigned to the user. These list is used to identify Vault groups to assign to the user using
  # group aliases.
  groups_claim          = var.oidc_config.groups_claim
  role_type             = "oidc"
  allowed_redirect_uris = [var.oidc_config.redirect_uri]

  # List of information that must be retrieved from the OIDC provider
  oidc_scopes = var.oidc_config.scopes

  # Set to true to debug OIDC issues (e.g. print token obtained by the user)
  verbose_oidc_logging = false
}

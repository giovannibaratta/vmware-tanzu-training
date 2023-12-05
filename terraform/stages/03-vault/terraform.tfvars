vault_address = "https://vault.gkube.it"

enable_oidc_auth = true

oidc_config = {
  client_id = "oidc-auth"
  user_claim = "preferred_username"
  groups_claim = "groups"
  discovery_url = "https://keycloak.gkube.it/realms/tanzu"
  scopes = ["openid", "profile", "groups"]
}
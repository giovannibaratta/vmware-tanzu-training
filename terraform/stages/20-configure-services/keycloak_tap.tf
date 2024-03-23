resource "keycloak_openid_client" "tap" {
  realm_id  = keycloak_realm.tanzu.id
  client_id = "tap-oidc"

  name    = "tap-oidc"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "https://tap-gui.tap.${var.domain}/api/auth/oidc/handler/frame"
  ]
}

resource "keycloak_openid_client_default_scopes" "tap" {
  realm_id  = keycloak_realm.tanzu.id
  client_id = keycloak_openid_client.tap.id

  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
}

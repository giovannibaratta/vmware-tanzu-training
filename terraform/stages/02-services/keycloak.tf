resource "keycloak_realm" "tanzu" {
  realm        = "tanzu"
  enabled      = true
  display_name = "Tanzu"

  login_theme = "base"

  ssl_required = "external"
}

resource "keycloak_openid_client_scope" "groups" {
  realm_id               = keycloak_realm.tanzu.id
  name                   = "groups"
  include_in_token_scope = true
}

resource "keycloak_generic_protocol_mapper" "saml_hardcode_attribute_mapper" {
  realm_id        = keycloak_realm.tanzu.id
  client_scope_id = keycloak_openid_client_scope.groups.id
  name            = "groups"
  protocol        = "openid-connect"
  protocol_mapper = "oidc-usermodel-realm-role-mapper"
  config = {
    "multivalued" : "true",
    "id.token.claim" : "true",
    "access.token.claim" : "true",
    "claim.name" : "groups",
    "jsonType.label" : "String"
  }
}
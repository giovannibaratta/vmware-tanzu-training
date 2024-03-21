resource "keycloak_realm" "tanzu" {
  realm        = "tanzu"
  enabled      = true
  display_name = "Tanzu"

  login_theme = "base"

  ssl_required = "external"
}

resource "keycloak_openid_client" "tmc" {
  realm_id  = keycloak_realm.tanzu.id
  client_id = "tmc-oidc"

  name    = "tmc-oidc"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true

  valid_redirect_uris = [
    "https://pinniped-supervisor.tmc.${var.domain}/provider/pinniped/callback"
  ]
}

resource "keycloak_openid_client_default_scopes" "tmc" {
  realm_id  = keycloak_realm.tanzu.id
  client_id = keycloak_openid_client.tmc.id

  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
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

resource "keycloak_role" "tmc_admin" {
  realm_id    = keycloak_realm.tanzu.id
  name        = "tmc:admin"
  description = "TMC admins"
}

resource "keycloak_role" "tmc_member" {
  realm_id    = keycloak_realm.tanzu.id
  name        = "tmc:member"
  description = "TMC members"
}

resource "keycloak_group" "tmc_admin" {
  realm_id = keycloak_realm.tanzu.id
  name     = "tmc:admin"
}

resource "keycloak_group_roles" "tmc_admin_bindings" {
  realm_id = keycloak_realm.tanzu.id
  group_id = keycloak_group.tmc_admin.id

  role_ids = [
    keycloak_role.tmc_admin.id
  ]
}

resource "keycloak_group" "tmc_member" {
  realm_id = keycloak_realm.tanzu.id
  name     = "tmc:member"
}

resource "keycloak_group_roles" "tmc_member_bindings" {
  realm_id = keycloak_realm.tanzu.id
  group_id = keycloak_group.tmc_member.id

  role_ids = [
    keycloak_role.tmc_member.id
  ]
}

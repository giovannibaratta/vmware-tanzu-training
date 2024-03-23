resource "keycloak_openid_client" "tmc" {
  realm_id  = keycloak_realm.tanzu.id
  client_id = "tmc-oidc"

  name    = "tmc-oidc"
  enabled = true

  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  // Required to login with the TMC CLI
  direct_access_grants_enabled = true

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

resource "vault_identity_group" "kv_ro" {
  name     = "kv-ro"
  type     = "external"
  policies = [vault_policy.kv_ro.name]
}

resource "vault_identity_group" "kv_rw" {
  name     = "kv-rw"
  type     = "external"
  policies = [vault_policy.kv_rw.name]
}

####################################################################################################
# Group aliases
#
# NB: The name property must matche the group name included in the token
# by the OIDC provider.
####################################################################################################

resource "vault_identity_group_alias" "oidc_kv_ro" {
  name           = "vault-kv-ro"
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.kv_ro.id
}

resource "vault_identity_group_alias" "oidc_kv_rw" {
  name           = "vault-kv-rw"
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = vault_identity_group.kv_rw.id
}
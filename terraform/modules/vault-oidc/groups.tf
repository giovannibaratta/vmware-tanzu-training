####################################################################################################
# Group aliases
#
# NB: The name property must matche the group name included in the token
# by the OIDC provider.
####################################################################################################

resource "vault_identity_group_alias" "mapping" {
  for_each = var.groups_mapping

  name           = each.key
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = each.value
}
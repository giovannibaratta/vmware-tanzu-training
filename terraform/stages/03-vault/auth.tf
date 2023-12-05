module "oidc-auth" {
  source = "../../modules/vault-oidc"

  oidc_config = merge(var.oidc_config, {
    redirect_uri = "${var.vault_address}/ui/vault/auth/oidc/oidc/callback"
  })

  oidc_config_sensitive = var.oidc_config_sensitive

  groups_mapping = {
    vault-kv-ro = vault_identity_group.kv_ro.id
    vault-kv-rw = vault_identity_group.kv_rw.id
  }
}

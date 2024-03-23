resource "terraform_data" "oidc_variable_cross_check" {
  triggers_replace = [ var.enable_oidc_auth, var.oidc_config, var.oidc_config_sensitive ]

  lifecycle {
    precondition {
      condition = var.enable_oidc_auth == false || (var.oidc_config != null && var.oidc_config_sensitive != null)
      error_message = "If enable_oidc_auth is true, oidc_config and oidc_config_sensitive must be defined"
    }
  }
}

module "oidc-auth" {
  count = var.enable_oidc_auth ? 1 : 0

  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vault-oidc?ref=vault-oidc-v0.0.1&depth=1"

  oidc_config = merge(var.oidc_config, {
    redirect_uri = "${var.vault_address}/ui/vault/auth/oidc/oidc/callback"
  })

  oidc_config_sensitive = var.oidc_config_sensitive

  groups_mapping = {
    vault-kv-ro = vault_identity_group.kv_ro.id
    vault-kv-rw = vault_identity_group.kv_rw.id
  }

  depends_on = [ terraform_data.oidc_variable_cross_check ]
}

module "kubernetes-auth" {
  count = var.enable_kubernetes_auth ? 1 : 0

  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vault-kubernetes?ref=vault-kubernetes-v0.0.1&depth=1"

  kubernetes_config = {
    host = var.kubernetes_auth_config.host
    ca = var.kubernetes_auth_config.ca
  }

  roles = {
    "legacy-app" = {
      name = "legacy-app"
      service_account_names = ["legacy-app"]
      namespaces = ["go-yada"]
      policies_to_attach = [vault_policy.kv_ro.name]
    }
  }
}
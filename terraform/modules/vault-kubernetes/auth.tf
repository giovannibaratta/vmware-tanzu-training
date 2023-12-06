resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "main" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_config.host
  kubernetes_ca_cert     = var.kubernetes_config.ca
  disable_iss_validation = "true"
}

resource "vault_kubernetes_auth_backend_role" "roles" {
  for_each = var.roles

  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = each.value.name
  bound_service_account_names      = each.value.service_account_names
  bound_service_account_namespaces = each.value.namespaces
  token_ttl                        = 3600
  token_policies                   = each.value.policies_to_attach
}
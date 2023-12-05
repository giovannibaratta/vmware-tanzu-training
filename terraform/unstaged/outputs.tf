resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/files/ansible/inventory.tpl", {
    keycloak_host_ip = vsphere_virtual_machine.keycloak.default_ip_address
    conjur_host_ip   = vsphere_virtual_machine.conjur.default_ip_address
    minio_host_ip   = try(vsphere_virtual_machine.minio[0].default_ip_address, "")
    vault_ips = [for node in module.vault_cluster.nodes: node.ip]
  })
  filename = "${path.module}/outputs/ansible_inventory"
}

resource "local_file" "keycloak_tls" {
  for_each = {
    "private-key" = acme_certificate.keycloak.private_key_pem
    "issuer" = acme_certificate.keycloak.issuer_pem
    "certificate" = acme_certificate.keycloak.certificate_pem
  }

  content = each.value
  filename = "${path.module}/outputs/keycloak/tls/${each.key}.pem"
}

resource "local_file" "vault_private_keys" {
  for_each = nonsensitive({ for node in module.vault_cluster.nodes: node.name => node.ssl.key if node.ssl != null})

  content = sensitive(each.value)
  filename = "${path.module}/outputs/vault/nodes/${each.key}/private-key.pem"
}

resource "local_file" "vault_certificate" {
  for_each = nonsensitive({ for node in module.vault_cluster.nodes: node.name => node.ssl.certificate if node.ssl != null})

  content = sensitive(each.value)
  filename = "${path.module}/outputs/vault/nodes/${each.key}/cert.pem"
}

resource "local_file" "vault_certificate_issuer" {
  for_each = nonsensitive({ for node in module.vault_cluster.nodes: node.name => node.ssl.certificate_issuer if node.ssl != null})

  content = sensitive(each.value)
  filename = "${path.module}/outputs/vault/nodes/${each.key}/issuer.pem"
}

resource "local_file" "vault_variables" {
  content = templatefile("${path.module}/files/vault/vault_cluster_variables.tpl", {
    cluster_name = module.vault_cluster.cluster.name
    cluster_api_fqdn = module.vault_cluster.cluster.api_fqdn
    seal_azure_tenant_id = data.azurerm_client_config.current.tenant_id
    seal_azure_client_id = azuread_application_registration.vault.client_id
    seal_azure_client_secret = azuread_application_password.vault.value
    seal_azure_vault = azurerm_key_vault.vault.name
    seal_azure_key = azurerm_key_vault_key.vault_seal.name
  })
  filename = "${path.module}/outputs/vault/cluster.vars"
}
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/files/ansible/inventory.tpl", {
    keycloak_host_ip = vsphere_virtual_machine.keycloak.default_ip_address
    conjur_host_ip   = vsphere_virtual_machine.conjur.default_ip_address
    minio_host_ip   = try(vsphere_virtual_machine.minio[0].default_ip_address, "")
    vault_ips = vsphere_virtual_machine.vault.*.default_ip_address
  })
  filename = "${path.module}/outputs/ansible_inventory"
}

resource "local_file" "vault_private_key" {
  count = local.vault_instances

  content = acme_certificate.vault_certificates[count.index].private_key_pem
  filename = "${path.module}/outputs/vault-${count.index}/private-key.pem"
}

resource "local_file" "vault_certificate" {
  count = local.vault_instances

  content = acme_certificate.vault_certificates[count.index].certificate_pem
  filename = "${path.module}/outputs/vault-${count.index}/certificate.pem"
}

resource "local_file" "vault_issuer" {
  count = local.vault_instances

  content = acme_certificate.vault_certificates[count.index].issuer_pem
  filename = "${path.module}/outputs/vault-${count.index}/issuer.pem"
}
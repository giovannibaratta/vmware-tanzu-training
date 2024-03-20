locals {
  ansible_files = [
    "keycloak.service.j2",
    "keycloak.conf.j2",
    "keycloak-environment.j2",
    "keycloak-tls-fullchain.j2",
    "keycloak-tls-key.j2"
  ]

  ansible_var_file = templatefile("${path.module}/files/keycloak-ansible-vars.yaml.tpl", {
    keycloak_db_password    = random_password.keycloak_db.result
    keycloak_admin_password = random_password.keycloak_admin.result
    keycloak_base64_tls_key = try(var.tls.private_key, null)
    keycloak_base64_tls_cert = try(var.tls.certificate, null)
    keycloak_base64_tls_ca_chain = try(var.tls.ca_chain, null)
  })
}

resource "random_password" "keycloak_admin" {
  length           = 10
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

resource "random_password" "keycloak_db" {
  length           = 20
  special          = true
  override_special = "#$%&*()=+[]{}<>:?"
}

module "vm" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vsphere-vm?ref=vsphere-vm-v0.0.3&depth=1"

  fqdn              = var.fqdn
  vsphere           = var.vsphere
  vm_authorized_key = var.vm_authorized_key

  ansible_playbook = filebase64("${path.module}/files/setup-playbook.yaml")

  cloud_init_write_files = merge(
    { for file in local.ansible_files : "/ansible/templates/${file}" => filebase64("${path.module}/files/${file}") },
    { "/ansible/vars.yaml" = base64encode(local.ansible_var_file) }
  )
}

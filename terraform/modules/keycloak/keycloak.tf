locals {
  ansible_files = ["keycloak.service.j2", "keycloak.conf.j2", "keycloak-environment.j2", "keycloak-tls-fullchain.j2"]
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

locals {
  ansible_playbook = templatefile("${path.module}/files/setup-playbook.yaml", {
    keycloak_db_password    = random_password.keycloak_db.result
    keycloak_admin_password = random_password.keycloak_admin.result
  })
}

module "vm" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vsphere-vm?ref=vsphere-vm-v0.0.3&depth=1"

  fqdn              = var.fqdn
  vsphere           = var.vsphere
  vm_authorized_key = var.vm_authorized_key

  ansible_playbook       = base64encode(local.ansible_playbook)
  cloud_init_write_files = { for file in local.ansible_files : "/ansible/templates/${file}" => filebase64("${path.module}/files/${file}") }
}

locals {

  harbor_config_file = templatefile("${path.module}/files/harbor-config.yml.tftpl", {
    fqdn : var.fqdn
    admin_password : random_password.admin_password.result
    db_root_password : random_password.db_root_password.result
  })
}

locals {
  ansible_files = [
    "harbor-systemd.service",
    "harbor-tls-ca-chain.j2",
    "harbor-tls-certificate.j2",
    "harbor-tls-key.j2"
  ]

  ansible_var_file = templatefile("${path.module}/files/harbor-ansible-vars.yaml.tpl", {
    harbor_hostname            = var.fqdn
    harbor_base64_tls_key      = try(var.tls.private_key, null)
    harbor_base64_tls_cert     = try(var.tls.certificate, null)
    harbor_base64_tls_ca_chain = try(var.tls.ca_chain, null)
  })
}

resource "random_password" "admin_password" {
  length           = 10
  special          = true
  override_special = "#$%*()=+[]{}:?"
}

resource "random_password" "db_root_password" {
  length           = 20
  special          = true
  override_special = "#$%*()=+[]{}:?"
}

module "vm" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vsphere-vm?ref=vsphere-vm-v0.0.3&depth=1"

  fqdn              = var.fqdn
  vsphere           = var.vsphere
  vm_authorized_key = var.vm_authorized_key

  ansible_playbook = filebase64("${path.module}/files/harbor-install-playbook.yaml")

  cloud_init_write_files = merge(
    { for file in local.ansible_files : "/ansible/templates/${file}" => filebase64("${path.module}/files/${file}") },
    {
      "/ansible/vars.yaml"         = base64encode(local.ansible_var_file),
      "/ansible/harbor-config.yml" = base64encode(local.harbor_config_file)
    }
  )

  ansible_galaxy_actions = [
    ["ansible-galaxy", "role", "install", "geerlingguy.docker"]
  ]
}

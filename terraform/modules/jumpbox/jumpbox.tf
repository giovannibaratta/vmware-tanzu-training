locals {
  ansible_playbook = file("${path.module}/files/setup-playbook.yaml")
}

module "vm" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vsphere-vm?ref=vsphere-vm-v0.0.3&depth=1"

  fqdn              = "jumpbox.${var.domain}"
  vsphere           = var.vsphere
  vm_authorized_key = var.vm_authorized_key

  ansible_playbook       = base64encode(local.ansible_playbook)
  ansible_galaxy_actions = [["ansible-galaxy", "role", "install", "geerlingguy.docker"]]
}

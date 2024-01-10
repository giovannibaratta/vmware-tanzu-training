resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/files/ansible/inventory.tpl", {
    bootstrap_host_ip = vsphere_virtual_machine.tgkm_bootstrap.default_ip_address
    keycloak_host_ip = vsphere_virtual_machine.keycloak.default_ip_address
  })
  filename = "${var.outputs_dir}/ansible_inventory"
}
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/files/ansible/inventory.tpl", {
    keycloak_host_ip = vsphere_virtual_machine.keycloak.default_ip_address
    conjur_host_ip   = vsphere_virtual_machine.conjur.default_ip_address
    minio_host_ip   = try(vsphere_virtual_machine.minio[0].default_ip_address, "")
  })
  filename = "${path.module}/outputs/ansible_inventory"
}
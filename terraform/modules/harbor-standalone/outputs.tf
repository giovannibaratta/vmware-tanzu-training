output "harbor_instance_ip" {
  value = vsphere_virtual_machine.harbor.default_ip_address
}
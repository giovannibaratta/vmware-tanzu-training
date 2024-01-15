output "jumpbox_instance_ip" {
  value = vsphere_virtual_machine.jumpbox.default_ip_address
}
output "harbor_instance_ip" {
  value = vsphere_virtual_machine.harbor.default_ip_address
}

output "harbor_admin_passowrd" {
  value = random_password.admin_password.result
}
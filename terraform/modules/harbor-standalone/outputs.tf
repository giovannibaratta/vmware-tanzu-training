output "instance_ip" {
  value = module.vm.instance_ip
}

output "harbor_admin_password" {
  value = random_password.admin_password.result
}
output "instance_ip" {
  value = module.vm.instance_ip
}

output "keycloak_admin_password" {
  value = random_password.keycloak_admin.result
}
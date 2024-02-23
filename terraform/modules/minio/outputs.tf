output "instance_ip" {
  value = module.vm.instance_ip
}

output "minio_root_password" {
  value = random_password.minio_root_password.result
}

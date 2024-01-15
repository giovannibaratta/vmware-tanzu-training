output "harbor" {
  value = {
    ip = module.harbor.harbor_instance_ip
  }
}
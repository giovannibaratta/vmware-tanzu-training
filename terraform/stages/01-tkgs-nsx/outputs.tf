output "ips" {
  value = {
    habror = module.harbor.harbor_instance_ip
    jumpbox = module.jumpbox.jumpbox_instance_ip
  }
}

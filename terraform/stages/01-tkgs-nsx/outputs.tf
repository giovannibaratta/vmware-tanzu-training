output "ips" {
  value = {
    habror = module.harbor.harbor_instance_ip
    jumpbox = module.jumpbox.jumpbox_instance_ip
    minio = module.minio.instance_ip
  }
}


resource "local_sensitive_file" "ansible_inventory" {
  count = var.sensitive_output_dir != null ? 1 : 0

  content = templatefile("${path.module}/files/sensitive.output.tpl", {
    minio_root_password = module.minio.minio_root_password
  })
  filename = "${var.sensitive_output_dir}/sensitive.output"
}
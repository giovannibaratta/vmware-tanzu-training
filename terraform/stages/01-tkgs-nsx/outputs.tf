output "ips" {
  value = {
    habror = try(module.harbor[0].harbor_instance_ip, null)
    jumpbox = try(module.jumpbox[0].jumpbox_instance_ip, null)
    minio = try(module.minio[0].instance_ip, null)
  }
}


resource "local_sensitive_file" "sensitive_output" {
  count = var.sensitive_output_dir != null ? 1 : 0

  content = templatefile("${path.module}/files/sensitive.output.tpl", {
    minio_root_password = try(module.minio[0].minio_root_password, "")
  })
  filename = "${var.sensitive_output_dir}/sensitive.output"
}
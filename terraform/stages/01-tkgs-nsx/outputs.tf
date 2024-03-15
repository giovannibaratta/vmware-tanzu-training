output "ips" {
  value = {
    for name, ip in {
      "registry" : try(module.harbor[0].harbor_instance_ip, null),
      "bastion" : try(module.jumpbox[0].jumpbox_instance_ip, null),
      "s3" : try(module.minio[0].instance_ip, null),
      "idp": try(module.keycloak[0].instance_ip, null),
    } : name => ip if ip != null
  }
}

locals {
  stage_output = {
    "registry_provider" = try({
      url = "https://${module.harbor[0].harbor_instance_ip}"
      username = "admin"
    }, null)
  }

  stage_sensitive_output = {
    "minio_root_password" = try(module.minio[0].minio_root_password, null),
    "registry_provider" = try({
      password = module.harbor[0].harbor_admin_passowrd
    }, null)
  }
}

resource "local_file" "stage_output" {
  count = var.output_dir != null ? 1 : 0

  content = jsonencode({
    for k,v in local.stage_output: k => v if v != null
  })

  filename = "${var.output_dir}/output.json"
}

resource "local_sensitive_file" "stage_sensitive_output" {
  count = var.sensitive_output_dir != null ? 1 : 0

  content = jsonencode({
    for k,v in local.stage_sensitive_output: k => v if v != null
  })

  filename = "${var.sensitive_output_dir}/sensitive-output.json"
}

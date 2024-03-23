locals {
  ansible_files = ["minio.service.j2", "minio-environment.j2"]
}

resource "random_password" "minio_root_password" {
  length           = 20
  special          = true
  override_special = "#%+=!"
}

locals {
  ansible_playbook = templatefile("${path.module}/files/setup-playbook.yaml", {
    minio_root_password = random_password.minio_root_password.result
  })
}

module "vm" {
  source = "github.com/giovannibaratta/vmware-tanzu-training//terraform/modules/vsphere-vm?ref=vsphere-vm-v0.0.3&depth=1"

  fqdn              = var.fqdn
  vsphere           = var.vsphere
  vm_authorized_key = var.vm_authorized_key

  ansible_playbook       = base64encode(local.ansible_playbook)
  cloud_init_write_files = { for file in local.ansible_files : "/ansible/templates/${file}" => filebase64("${path.module}/files/${file}") }
}

data "http" "minio_healthcheck" {
  url                = "https://${module.vm.instance_ip}/minio/health/live"
  method             = "GET"
  insecure           = true
  request_timeout_ms = 5000

  retry {
    attempts     = 2     # equals to 3 attempts
    min_delay_ms = 30000 # 30s
    max_delay_ms = 60000 # 60s
  }

  lifecycle {
    postcondition {
      condition     = self.status_code == 200
      error_message = "MinIO healtcheck failed"
    }
  }

  depends_on = [module.vm]
}

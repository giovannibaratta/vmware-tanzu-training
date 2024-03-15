provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "harbor" {
  url      = "https://${try(module.harbor[0].harbor_instance_ip, "")}"
  username = "admin"
  password = try(module.harbor[0].harbor_admin_passowrd, "")
  insecure = true
}

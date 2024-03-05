provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "harbor" {
  url      = "https://${module.harbor.harbor_instance_ip}"
  username = "admin"
  password = module.harbor.harbor_admin_passowrd
  insecure = true
}

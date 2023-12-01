provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "desec" {
  api_token = var.desec_token
}

provider "avi" {
  avi_username = var.avi.username
  avi_tenant = var.avi.tenant
  avi_password = local.avi.password
  avi_controller = var.avi.controller
  avi_version = var.avi.version
}
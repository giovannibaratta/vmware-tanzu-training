provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.supervisor_context_name
}

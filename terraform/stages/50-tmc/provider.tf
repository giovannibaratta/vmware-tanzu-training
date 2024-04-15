provider "tanzu-mission-control" {
  endpoint = "tmc.${var.domain}"

  self_managed {
    oidc_issuer = "pinniped-supervisor.tmc.${var.domain}"
    username    = var.tmc_admin_user.username
    password    = var.tmc_admin_user.password
  }

  ca_cert = var.ca_certificate
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.supervisor_context_name
}

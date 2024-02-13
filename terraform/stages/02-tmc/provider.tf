provider "tanzu-mission-control" {
  endpoint = var.tmc.endpoint

  self_managed {
    oidc_issuer = var.tmc.oidc_issuer
    username    = var.tmc.username
    password    = var.tmc.password
  }

  ca_cert = var.tmc.ca_cert
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.supervisor_context_name
}
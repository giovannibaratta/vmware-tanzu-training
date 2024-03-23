provider "harbor" {
  url      = var.registry_provider.url
  username = var.registry_provider.username
  password = var.registry_provider.password
  insecure = true
}

provider "keycloak" {
  client_id           = "admin-cli"
  username            = var.idp_provider.username
  password            = var.idp_provider.password
  url                 = var.idp_provider.url
  root_ca_certificate = var.idp_provider.root_ca
}

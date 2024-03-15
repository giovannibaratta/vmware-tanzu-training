provider "harbor" {
  url      = var.registry_provider.url
  username = var.registry_provider.username
  password = var.registry_provider.password
  insecure = true
}
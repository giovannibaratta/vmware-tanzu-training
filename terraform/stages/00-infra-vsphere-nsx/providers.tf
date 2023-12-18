provider "nsxt" {
  host                 = var.nsxt_config.host
  username             = var.nsxt_config.username
  password             = var.nsxt_config_sensitive.password
  allow_unverified_ssl = var.nsxt_config.allow_unverified_ssl
  max_retries          = 2
}
variable "oidc_config" {
  type = object({
    client_id = string
    discovery_url = string
    user_claim = string
    groups_claim = string
    scopes = set(string)
    redirect_uri = string
  })
}

variable "oidc_config_sensitive" {
  sensitive = true
  type = object({
    client_secret = string
  })
}

variable "groups_mapping" {
  type = map(string)
  default = {}
  description = "Map OIDC groups to groups managed by Vault. The key is the OIDC group name and the value is the Vault group id"
}
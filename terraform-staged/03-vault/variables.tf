variable "vault_address" {
  type = string
}

variable "token" {
  type = string
  sensitive = true
}

variable "oidc_config" {
  type = object({
    client_id = string
    discovery_url = string
    user_claim = string
    groups_claim = string
    scopes = set(string)
  })
}

variable "odic_config_sensitive" {
  sensitive = true
  type = object({
    client_secret = string
  })
}
variable "vault_address" {
  type        = string
  description = "Vault server address"
}

variable "token" {
  type        = string
  description = "Vault token"
  sensitive   = true
}

variable "enable_oidc_auth" {
  default     = false
  type        = bool
  description = "Configure OIDC authentication in Vault."
}

variable "oidc_config" {
  default     = null
  nullable    = true
  description = "Parameters to configure OIDC auth. Required if enable_oidc_auth is true"

  type = object({
    client_id     = string
    discovery_url = string
    user_claim    = string
    groups_claim  = string
    scopes        = set(string)
  })
}

variable "oidc_config_sensitive" {
  sensitive   = true
  default     = null
  nullable    = true
  description = "Parameters to configure OIDC auth. Required if enable_oidc_auth is true"

  type = object({
    client_secret = string
  })
}

variable "enable_kubernetes_auth" {
  default     = false
  type        = bool
  description = "Configure Kubernetes authentication in Vault."
}

variable "kubernetes_auth_config" {
  nullable = true
  default = null
  description = "Must be set if enable_kubernetes_auth is true. Host is the Kubernetes server that will validate the JWT token received by the Agent injector."

  type = object({
    host = string
    ca = string
  })
}
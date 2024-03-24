variable "add_trust_to_kapp_controller" {
  type        = bool
  description = "Configure the Kapp controller to trust the private registry"
  default     = true
}

variable "domain" {
  type = string
}

variable "ca_certificate" {
  type        = string
  description = "Certificate used to configure the cluster issuer"
}

variable "ca_private_key" {
  type        = string
  sensitive   = true
  description = "Private key used to configure the cluster issuer"
}

variable "tmc_oidc_provider" {
  type = object({
    client_id     = string
    client_secret = string
    issuer_url    = string
  })
}

variable "kubeconfigs" {
  type      = map(string)
  sensitive = true
}

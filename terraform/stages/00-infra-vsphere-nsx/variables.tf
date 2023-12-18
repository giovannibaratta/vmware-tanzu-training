variable "nsxt_config" {
  type = object({
    host                 = string
    username             = string
    allow_unverified_ssl = bool
  })

  description = "Information to connect to the NSX manager"
}

variable "nsxt_config_sensitive" {
  type = object({
    password = string
  })

  sensitive   = true
  description = "Information to connect to the NSX manager"
}
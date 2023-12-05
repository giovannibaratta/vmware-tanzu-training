variable "num_nodes" {
  type = number
  default = 1
}

variable "domain" {
  description = "Domain used for DNS registration and hostnames"
  default = "local.lan"
  type = string
}

variable "vip" {
  description = "Expected virtual IP used to expose the Vault cluster"
  type = string
  default = null
  nullable = true
}

variable "register_dns" {
  description = "Register DNS for each instance"
  default = false
  type = bool
}

variable "generate_certificates" {
  description = "Generate certificate using Let's encrypt"
  default = false
  type = bool
}

variable "certificate_dns_challenge_token" {
  default = null
  type = string
  sensitive = true
  nullable = true
}

variable "vsphere" {
  type = object({
    resource_pool_id = string
    datastore_id = string
    port_group_id = string
    template_id = string
  })
}

variable "deploy_load_balancer" {
  description = "If true, a load balancer will be deployed using NSX ALB"
  type = bool
  default = false
}

variable "avi" {
  nullable = true
  default = null
  type = object({
    cloud_id = string
  })
}
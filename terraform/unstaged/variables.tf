variable "vsphere_server" {
  type = string
}

variable "vsphere_user" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "hosts" {
  type = set(string)
}

variable "deployments" {
  type = object({
    haproxy = optional(bool, false)
    minio = optional(bool, false)
  })

  description = "Set to true to deploy the virtual machine"
}

variable "haproxy_specs" {
  type = object({
    management = object({
      ip_cidr = string
      gateway = string
    })

    workload = object({
      ip_cidr = string
      gateway = string
    })

    frontend = object({
      ip_cidr = string
      gateway = string
    })

    service_cidr = string

    hostname    = optional(string, "haproxy")
    nameservers = optional(string, "1.1.1.1,8.8.8.8")
    user        = optional(string, "haproxy")
  })

  description = "If deploy_haproxy is set to true, this variable is mandatory"
  default     = null
  nullable    = true
}

variable "haproxy_sensitive_specs" {
  type = object({
    root_pwd = string
    user_pwd = string
  })

  description = "If deploy_haproxy is set to true, this variable is mandatory"
  default     = null
  sensitive   = true
  nullable    = true
}

variable "desec_token" {
  sensitive = true
  type = string
  description = "Token used to generate DNS records and ACME challeneges in desec.io"
}

variable "avi" {
  type = object({
    username = string
    tenant = string
    controller = string
    version = string
    cloud_name = string
  })
}

variable "avi_sensitive" {
  sensitive = true
  type = object({
    password = string
  })
}

variable "vault" {
  type = object({
    vip = string
    num_instances = number
  })
}

variable "domain" {
  type = string
}
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

variable "vcenter_data" {
  type = object({
    datacenter_name   = string
    cluster_name      = string
    datastore_name    = string
    mgmt_segment_name = string
  })
}

variable "domain" {
  type = string
}

variable "vm_authorized_key" {
  type = string
}

variable "sensitive_output_dir" {
  type     = string
  default  = null
  nullable = true
}

variable "services" {
  description = "Select the services that must be deployed"

  type = object({
    bastion  = optional(bool, true)
    registry = optional(bool, false)
    s3       = optional(bool, false)
    idp      = optional(bool, false)
  })

  default = {}
}

variable "registry_projects" {
  description = "List of projects that must be created in the registry"

  type    = set(string)
  default = []
}

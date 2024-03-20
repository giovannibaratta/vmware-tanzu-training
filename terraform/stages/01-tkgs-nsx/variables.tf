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

variable "output_dir" {
  type     = string
  default  = null
  nullable = true

  validation {
    condition = !endswith(var.output_dir, "/")
    error_message = "The path should not end with /"
  }
}

variable "sensitive_output_dir" {
  type     = string
  default  = null
  nullable = true

  validation {
    condition = !endswith(var.sensitive_output_dir, "/")
    error_message = "The path should not end with /"
  }
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

variable "supervisor_context_name" {
  description = "Name of the supervisor context in .kube/config"
  type        = string
  nullable = true
  default = null
}

variable "tkgs_clusters" {
  type = list(object({
    control_plane_replicas = optional(number, 1)
    worker_node_replicas = optional(number, 3)
    namespace = string
    name = string
  }))

  default = []

  validation {
    condition = length(toset([ for v in var.tkgs_clusters: "${v.namespace}/${v.name}" ])) == length(var.tkgs_clusters)
    error_message = "Duplicated namespace/name pair found in the list"
  }
}

variable "ca_private_key" {
  description = "Private key in PEM format used to generate certificates"
  type = string
  sensitive = true
}

variable "ca_certificate" {
  description = "Certificate in PEM format of the CA"
  type = string
}

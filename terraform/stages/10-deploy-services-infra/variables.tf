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

variable "vm_template" {
  type = object({
    library_name  = string
    template_name = string
  })
  description = "Reference to an existing template. If not set, an Ubuntu ova image will be uploaded."
  nullable    = true
  default     = null
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
    condition     = !endswith(var.output_dir, "/")
    error_message = "The path should not end with /"
  }
}

variable "sensitive_output_dir" {
  type     = string
  default  = null
  nullable = true

  validation {
    condition     = !endswith(var.sensitive_output_dir, "/")
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

variable "ca_private_key" {
  description = "Private key in PEM format used to generate certificates"
  type        = string
  sensitive   = true
}

variable "ca_certificate" {
  description = "Certificate in PEM format of the CA"
  type        = string
}

variable "docker_daemon_options" {
  type     = map(any)
  nullable = true
  default  = null
}

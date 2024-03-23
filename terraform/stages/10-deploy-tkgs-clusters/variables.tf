variable "kubeconfig_path" {
  type        = string
  default     = null
  nullable    = true
  description = "Path to the kubeconfig to use"
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

variable "supervisor_context_name" {
  description = "Name of the supervisor context in .kube/config"
  type        = string
  nullable    = true
  default     = null
}

variable "tkgs_clusters" {
  type = list(object({
    control_plane_replicas = optional(number, 1)
    worker_node_replicas   = optional(number, 3)
    namespace              = string
    name                   = string
    tkr                    = string
    storage_class          = string
    vm_class               = string
  }))

  default = []

  validation {
    condition     = length(toset([for v in var.tkgs_clusters : "${v.namespace}/${v.name}"])) == length(var.tkgs_clusters)
    error_message = "Duplicated namespace/name pair found in the list"
  }
}

variable "ca_certificate" {
  description = "Certificate in PEM format of the CA"
  type        = string
}

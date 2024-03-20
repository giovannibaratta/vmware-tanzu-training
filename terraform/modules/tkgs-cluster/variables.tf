variable "supervisor_context_name" {
  type = string
  default = null
  nullable = true
}

variable "cluster_name" {
  type = string
}

variable "cluster_namespace" {
  type = string
}

variable "control_plane_replicas" {
  type = number
  default = 1
}

variable "worker_node_replicas" {
  type = number
  default = 3
}

variable "vm_class" {
  type = string
}

variable "storage_class" {
  type = string
}

variable "tkr" {
  type = string
}

variable "desired_state" {
  type = string
  default = "PRESENT"

  validation {
    condition = contains(["PRESENT", "DELETED"], var.desired_state)
    error_message = "Allowed values are PRESENT, DELETED"
  }
}

variable "additional_ca" {
  type = string
  description = "CA bundle to inject in the nodes in PEM format"
  nullable = true
  default = null
}
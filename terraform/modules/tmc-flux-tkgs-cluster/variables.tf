variable "cluster_name" {
  type = string
}

variable "cluster_namespace" {
  type = string
}

variable "vm_class" {
  type = string
}

variable "storage_class_name" {
  type = string
}

variable "cluster_group" {
  type = string
  default = null
  nullable = true
}

variable "managed_by" {
  description = "Name of the supervisor cluster that will manage the cluster"
  type = string
}

variable "worker_nodes_replicas" {
  type = number
  default = 3
}

variable "control_plane_replicas" {
  type = number
  default = 1
}

variable "cluster_additional_trusted_cas" {
  type = string
  default = null
  nullable = true
}

variable "git_repo_credentials" {
  type = object({
    type = string
    ssh = optional(object({
      identity    = string
      known_hosts = string
    }))
    user_pass = optional(object({
      username = string
      password = string
    }))
  })

  sensitive = true
  nullable  = true
  default   = null

  validation {
   condition = var.git_repo_credentials == null || try(contains(["ssh", "user_pass"], var.git_repo_credentials.type), false)
   error_message = "supported values for type are 'ssh' or 'user_pass'"
  }

  validation {
    condition = var.git_repo_credentials == null || try(var.git_repo_credentials.type != "ssh" || var.git_repo_credentials.ssh != null, false)
    error_message = "If type is 'ssh' the 'ssh' object must be set"
  }

  validation {
    condition = var.git_repo_credentials == null || try(var.git_repo_credentials.type != "user_pass" || var.git_repo_credentials.user_pass != null, false)
    error_message = "If type is 'ssh' the 'ssh' object must be set"
  }
}

variable "git_repo_url" {
  type        = string
  description = "The URL should not include https and there shouldn't be any trailing /"
}

variable "git_branch" {
  type        = string
  description = "The URL should not include https and there shouldn't be any trailing /"
  default = "main"
}

variable "cluster_overlay_path" {
  type = string
  description = "Path in the Git repo that contains the kustomization.yaml file for the cluster"
}
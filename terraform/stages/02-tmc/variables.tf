variable "tmc" {
  description = "Attributes used to configure the TMC provider"
  type = object({
    endpoint    = string
    oidc_issuer = string
    username    = string
    password    = string
    ca_cert     = string
  })
}

variable "supervisor_context_name" {
  description = "Name of the supervisor context in .kube/config"
  type        = string
}

variable "clusters_additional_trusted_cas" {
  type        = string
  description = "Additional CA in PEM encoding. The CAs can be concatenated"
  nullable    = true
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

variable "gitops_repo_root_folder" {
  type        = string
  description = "path of folder containing the root kustomization.yaml"
  default     = ""
}

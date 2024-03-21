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
}

variable "git_repo_url" {
  type        = string
  description = "The URL should not include https and there shouldn't be any trailing /"
}

variable "gitops_repo_cluster_root_folder" {
  type        = string
  description = "path of folder containing the root kustomization.yaml"
  default     = ""
}

variable "age_secret_key" {
  sensitive = true
  type = string

  validation {
    condition = startswith(var.age_secret_key, "AGE-SECRET-KEY-")
    error_message = "Key must start with AGE-SECRET-KEY-"
  }
}

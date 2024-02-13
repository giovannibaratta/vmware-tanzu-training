variable "tmc" {
  description = "Attributes used to configure the TMC provider"
  type = object({
    endpoint = string
    oidc_issuer = string
    username = string
    password = string
    ca_cert = string
  })
}

variable "supervisor_context_name" {
  description = "Name of the supervisor context in .kube/config"
  type = string
}

variable "clusters_additional_trusted_cas" {
  type = string
  description = "Additional CA in PEM encoding. The CAs can be concatenated"
  nullable = true
}

variable "git_repo_credentials" {
  type = object({
    username = string
    password = string
  })

  sensitive = true
}

variable "git_repo_url" {
  type = string
  description = "The URL should not include https and there shouldn't be any trailing /"
}
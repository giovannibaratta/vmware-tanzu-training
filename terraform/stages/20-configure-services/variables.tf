variable "registry_provider" {
  type = object({
    url = string
    username = string
    password = string
  })

  nullable = true
  default = null
}

variable "idp_provider" {
  type = object({
    url = string
    username = string
    password = string
    root_ca = string
  })

  nullable = true
  default = null
}

variable "registry_projects" {
  description = "List of projects that must be created in the registry"

  type    = set(string)
  default = []
}

variable "domain" {
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
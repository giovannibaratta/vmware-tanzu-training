variable "registry_provider" {
  type = object({
    url = string
    username = string
    password = string
  })

  nullable = true
  default = null
}

variable "registry_projects" {
  description = "List of projects that must be created in the registry"

  type    = set(string)
  default = []
}

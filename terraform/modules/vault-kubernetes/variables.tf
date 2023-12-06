variable "kubernetes_config" {
  type = object({
    host = string
    ca = string
  })
}

variable "roles" {
  type = map(object({
    name = string
    service_account_names = optional(set(string), ["*"])
    namespaces = set(string)
    policies_to_attach = optional(set(string), [])
  }))

  default = {}
}
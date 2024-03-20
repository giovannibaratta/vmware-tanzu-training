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
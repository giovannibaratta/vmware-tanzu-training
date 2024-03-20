variable "tmc_kubeconfig" {
  type = string
  description = "Path to a kubeconfig for the tmc cluster"
}

variable "add_trust_to_kapp_controller" {
  type = bool
  description = "Configure the Kapp controller to trust the private registry"
  default = true
}

variable "private_registry_ca" {
  type = string
  description = "PEM certificate of the private registry that contains the TMC images"
}

variable "tmc_repo_ref" {
  type = string
  description = "Reference to the private registry that contains the images. Example: harbor.h2o-2-22574.h2o.vmware.com/tmc-sm/package-repository:1.1.0"
}

variable "tmc_values" {
  type = string
  description = "TMC values"
  sensitive = true
}
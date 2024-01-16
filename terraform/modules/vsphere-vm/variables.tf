variable "root_password" {
  type = string
  nullable = true
  description = "Password to assign to the root user. If no value is provided a random password will be generated."
  default = null
}

variable "cloud_init" {
  type = string
  nullable = true
  description = "Custom cloud-init to use instead of the default provided by the module. If a custom value is provided, most of the configuration set in the variable will not be applied (including ssh keys and the Ansible playbook). It must be a base64 encoded string"
  default = null
}

variable "vm_authorized_key" {
  description = "Public key authorized to ssh into the VM"
  type = string
}

variable "cloud_init_write_files" {
  type = map(string)
  description = "Additional files to push using cloud-init. The key is the destination path in the VM and the value is the content in base64 encodeding."
  default = {}
}

variable "ansible_playbook" {
  type = string
  description = "base64 encoded playbook"
  nullable = true
  default = null
}

variable "ansible_galaxy_actions" {
  type = list(list(string))
  description = "Additional Ansible galaxy actions to perform during cloud-init"
  default = []
}

variable "fqdn" {
  type = string
  description = "Fully qualified domain name of the VM"
}

variable "vsphere" {
  description = "vSphere related references to deploy the VM"

  type = object({
    resource_pool_id = string
    datastore_id = string
    network_id = string
    template_id = string
  })
}

variable "vm_specs" {
  type = object({
    cpu = optional(number, 2)
    memory = optional(number, 4096)
    disk_size = optional(number, 50)
  })

  default = {}
}

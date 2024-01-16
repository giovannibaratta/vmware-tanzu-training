variable "vm_authorized_key" {
  description = "Public key authorized to ssh into the VM"
  type = string
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

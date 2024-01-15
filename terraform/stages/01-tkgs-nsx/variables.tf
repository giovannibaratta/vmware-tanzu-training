variable "vsphere_server" {
  type = string
}

variable "vsphere_user" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vcenter_data" {
  type = object({
    datacenter_name = string
    cluster_name = string
    datastore_name = string
    mgmt_segment_name = string
  })
}

variable "domain" {
  type = string
}

variable "vm_authorized_key" {
  type = string
}
variable "vcenter_server" {
  type = string
}

variable "vcenter_user" {
  type    = string
  default = "administrator@vsphere.local"
}

variable "vcenter_password" {
  type      = string
  sensitive = true
}

variable "datacenter" {
  type = string
}

variable "cluster" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}
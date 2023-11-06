data "vsphere_datacenter" "datacenter" {
  name = "dc01"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "vc01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "mgmt" {
  name          = "management-portgroup-1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_content_library" "templates" {
  name = "Templates"
}

data "vsphere_content_library_item" "debian_goldenimage" {
  name       = "debian-goldenimage"
  type       = "ovf"
  library_id = data.vsphere_content_library.templates.id
}

resource "vsphere_resource_pool" "mgmt" {
  name                    = "mgmt"
  parent_resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
}